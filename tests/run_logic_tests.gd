extends SceneTree

const CharacterProfile = preload("res://scripts/save/character_profile.gd")
const Cooldown = preload("res://scripts/combat/cooldown.gd")
const DifficultyScaler = preload("res://scripts/core/difficulty_scaler.gd")
const EnemyActivationManager = preload("res://scripts/enemies/enemy_activation_manager.gd")
const EnemyCatalog = preload("res://scripts/enemies/enemy_catalog.gd")
const EnemyController = preload("res://scripts/enemies/enemy_controller.gd")
const BossController = preload("res://scripts/enemies/boss_controller.gd")
const InventoryModel = preload("res://scripts/inventory/inventory_model.gd")
const LootTable = preload("res://scripts/loot/loot_table.gd")
const Progression = preload("res://scripts/core/progression.gd")
const Projectile = preload("res://scripts/combat/projectile.gd")
const ProjectilePool = preload("res://scripts/combat/projectile_pool.gd")
const RaceData = preload("res://scripts/core/race_data.gd")
const QuestTracker = preload("res://scripts/quests/quest_tracker.gd")
const WaypointRegistry = preload("res://scripts/world/waypoint_registry.gd")

var _failures := 0


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	_test_progression_and_level_cap()
	_test_cooldown_readiness()
	_test_party_difficulty_values()
	_test_inventory_stack_bounds()
	_test_profile_round_trip_and_migration()
	_test_quest_chain()
	_test_waypoint_activation()
	_test_deterministic_loot_selection()
	_test_projectile_pool_reuses_and_expires_objects()
	_test_enemy_activation_radius()
	if _failures > 0:
		push_error("Fractureborn logic tests failed: %d checks." % _failures)
		quit(1)
	else:
		print("Fractureborn logic tests passed.")
		quit(0)


func _expect(condition: bool) -> void:
	if not condition:
		_failures += 1
		push_error("Logic check failed.")


func _test_progression_and_level_cap() -> void:
	var profile = CharacterProfile.new("Mira")
	_expect(Progression.exp_to_next_level(1) > 0)
	_expect(Progression.apply_experience(profile, Progression.exp_to_next_level(1)) == 1)
	_expect(profile.level == 2)
	_expect(profile.max_hp > 100)
	Progression.apply_experience(profile, 10000000)
	_expect(profile.level == 50)
	_expect(profile.exp == 0)


func _test_cooldown_readiness() -> void:
	var cooldown = Cooldown.new()
	_expect(cooldown.is_ready())
	cooldown.start(1.2)
	_expect(not cooldown.is_ready())
	cooldown.tick(0.7)
	_expect(is_equal_approx(cooldown.remaining, 0.5))
	cooldown.tick(0.5)
	_expect(cooldown.is_ready())


func _test_party_difficulty_values() -> void:
	_expect(is_equal_approx(DifficultyScaler.enemy_hp_multiplier(1), 1.0))
	_expect(is_equal_approx(DifficultyScaler.enemy_hp_multiplier(2), 1.5))
	_expect(is_equal_approx(DifficultyScaler.enemy_hp_multiplier(3), 2.0))
	_expect(is_equal_approx(DifficultyScaler.enemy_hp_multiplier(4), 2.6))
	_expect(is_equal_approx(DifficultyScaler.enemy_damage_multiplier(1), 1.0))
	_expect(is_equal_approx(DifficultyScaler.enemy_damage_multiplier(2), 1.15))
	_expect(is_equal_approx(DifficultyScaler.enemy_damage_multiplier(3), 1.30))
	_expect(is_equal_approx(DifficultyScaler.enemy_damage_multiplier(4), 1.45))
	_expect(is_equal_approx(DifficultyScaler.enemy_hp_multiplier(5), 2.6))
	_expect(RaceData.playable_races() == [&"HUMAN"])
	_expect(RaceData.is_defined(&"DEMON"))
	_expect(not RaceData.is_playable(&"DEMON"))


func _test_inventory_stack_bounds() -> void:
	var inventory = CharacterProfile.new("Mira").inventory
	_expect(InventoryModel.add(inventory, "materials", "sunleaf", 3))
	_expect(InventoryModel.quantity(inventory, "materials", "sunleaf") == 3)
	_expect(not InventoryModel.remove(inventory, "materials", "sunleaf", 4))
	_expect(InventoryModel.quantity(inventory, "materials", "sunleaf") == 3)
	_expect(InventoryModel.remove(inventory, "materials", "sunleaf", 2))
	_expect(InventoryModel.quantity(inventory, "materials", "sunleaf") == 1)


func _test_profile_round_trip_and_migration() -> void:
	var profile = CharacterProfile.new("Mira")
	profile.level = 7
	profile.gold = 91
	profile.activated_waypoints.append("village_well")
	var loaded = CharacterProfile.from_dict(profile.to_dict())
	_expect(loaded.character_name == "Mira")
	_expect(loaded.level == 7)
	_expect(loaded.gold == 91)
	_expect(loaded.activated_waypoints.has("village_well"))
	var migrated = CharacterProfile.from_dict({"version": 0, "name": "Old Save", "race": "INVALID", "level": 4, "gold": 12})
	_expect(migrated.character_name == "Old Save")
	_expect(migrated.race_id == "HUMAN")
	_expect(migrated.level == 4)
	_expect(migrated.gold == 12)


func _test_quest_chain() -> void:
	var quest = QuestTracker.new()
	quest.record_kill()
	_expect(quest.kill_count == 1)
	_expect(quest.accept())
	quest.enter_plains()
	for index in range(quest.definition.required_kills - quest.kill_count):
		quest.record_kill()
	quest.activate_waypoint()
	quest.defeat_boss("goblin_captain")
	_expect(not quest.can_turn_in())
	quest.defeat_boss("ancient_treant")
	_expect(quest.can_turn_in())
	_expect(quest.turn_in())
	_expect(quest.completed)
	_expect(not quest.turn_in())


func _test_waypoint_activation() -> void:
	var profile = CharacterProfile.new("Mira")
	_expect(WaypointRegistry.activate(profile, "village_well"))
	_expect(not WaypointRegistry.activate(profile, "village_well"))
	_expect(WaypointRegistry.is_activated(profile, "village_well"))
	_expect(WaypointRegistry.latest(profile) == "village_well")


func _test_deterministic_loot_selection() -> void:
	var table = LootTable.new()
	table.entries.append({"item_id": "sunleaf", "weight": 1.0})
	var rng = RandomNumberGenerator.new()
	rng.seed = 17
	_expect(table.roll(rng) == "sunleaf")


func _test_projectile_pool_reuses_and_expires_objects() -> void:
	var pool = ProjectilePool.new()
	pool.initial_capacity = 0
	pool.maximum_capacity = 1
	root.add_child(pool)
	_expect(pool.fire(Vector2.ZERO, Vector2.RIGHT, "player", 5, 500.0, 32.0, 0.0, 0.0))
	_expect(pool.total_count() == 1)
	_expect(not pool.fire(Vector2.ZERO, Vector2.RIGHT, "player", 5, 500.0, 32.0, 0.0, 0.0))
	var projectile: Projectile = pool.get_child(0)
	_expect(projectile.collision_layer == Projectile.PLAYER_PROJECTILE_LAYER)
	_expect(projectile.collision_mask == Projectile.ENEMY_LAYER)
	projectile._physics_process(1.0)
	_expect(pool.active_count == 0)
	_expect(pool.fire(Vector2.ZERO, Vector2.LEFT, "enemy", 5, 500.0, 32.0, 0.0, 0.0))
	_expect(pool.total_count() == 1)
	projectile.deactivate()
	pool.queue_free()


func _test_enemy_activation_radius() -> void:
	var target := Node2D.new()
	root.add_child(target)
	var pool = ProjectilePool.new()
	pool.initial_capacity = 0
	root.add_child(pool)
	var manager = EnemyActivationManager.new()
	manager.active_radius = 100.0
	manager.boss_active_radius = 50.0
	root.add_child(manager)
	manager.configure(target)
	var boss: BossController = BossController.new()
	boss.configure_boss(EnemyCatalog.get_definition(&"goblin_captain"), &"goblin_captain", target, pool, manager, 1)
	boss.position = Vector2(75, 0)
	root.add_child(boss)
	manager.register_enemy(boss)
	_expect(not boss.is_active)
	var enemy: EnemyController = EnemyController.new()
	enemy.configure(EnemyCatalog.get_definition(&"slime"), target, pool, manager, 1)
	enemy.position = Vector2(500, 0)
	root.add_child(enemy)
	manager.register_enemy(enemy)
	_expect(not enemy.is_active)
	_expect(not manager.active_enemies.has(enemy))
	target.position = Vector2(40, 0)
	manager.refresh_activity()
	_expect(boss.is_active)
	target.position = Vector2(480, 0)
	manager.refresh_activity(true)
	_expect(enemy.is_active)
	_expect(manager.active_enemies.has(enemy))
	boss.queue_free()
	enemy.queue_free()
	manager.queue_free()
	pool.queue_free()
	target.queue_free()
