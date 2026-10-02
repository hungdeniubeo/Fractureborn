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
const LootService = preload("res://scripts/loot/loot_service.gd")
const Progression = preload("res://scripts/core/progression.gd")
const Projectile = preload("res://scripts/combat/projectile.gd")
const ProjectilePool = preload("res://scripts/combat/projectile_pool.gd")
const RaceData = preload("res://scripts/core/race_data.gd")
const QuestTracker = preload("res://scripts/quests/quest_tracker.gd")
const WaypointRegistry = preload("res://scripts/world/waypoint_registry.gd")


class HitTarget extends Node2D:
	var damage_received := 0

	func take_damage(amount: int, _stagger: float = 0.0, _knockback: Vector2 = Vector2.ZERO) -> void:
		damage_received += amount


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
	_test_guaranteed_loot_selection()
	_test_boss_stagger_and_phase_patterns()
	_test_normal_enemy_health_bar_tracks_authoritative_health()
	_test_editor_authored_ui_layouts()
	_test_editor_authored_maps()
	_test_projectile_pool_reuses_and_expires_objects()
	_test_enemy_activation_radius()
	if _failures > 0:
		push_error("Fractureborn logic tests failed: %d checks." % _failures)
		quit(1)
	else:
		print("Fractureborn logic tests passed.")
		quit(0)


func _expect(condition: bool, description: String = "") -> bool:
	if not condition:
		_failures += 1
		push_error("Logic check failed: %s" % description)
	return condition


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


func _test_guaranteed_loot_selection() -> void:
	var table = LootTable.new()
	table.guaranteed_entries.append({"item_id": "iron_sword", "category": "weapons", "count": 1})
	table.entries.append({"item_id": "moss_fragment", "category": "materials", "count": 2, "weight": 1.0})
	var rng = RandomNumberGenerator.new()
	rng.seed = 25
	var drops: Array[Dictionary] = LootService.roll_drops(table, rng)
	_expect(drops.size() == 2)
	_expect(drops[0].get("item_id", "") == "iron_sword")
	_expect(drops[1].get("item_id", "") == "moss_fragment")
	var captain_table: LootTable = load("res://data/loot/captain_bounty.tres")
	var captain_drops: Array[Dictionary] = LootService.roll_drops(captain_table, rng)
	_expect(captain_drops.size() == 2 and captain_drops[0].get("item_id", "") == "iron_sword")


func _test_boss_stagger_and_phase_patterns() -> void:
	var target := HitTarget.new()
	root.add_child(target)
	var manager = EnemyActivationManager.new()
	root.add_child(manager)
	var captain = BossController.new()
	captain.configure_boss(EnemyCatalog.get_definition(&"goblin_captain"), &"goblin_captain", target, null, manager)
	root.add_child(captain)
	var observed := {"maximum": 0.0}
	captain.stagger_changed.connect(func(_current: float, maximum: float): observed.maximum = maximum)
	captain.take_damage(1, 20.0)
	_expect(float(observed.maximum) == captain.stagger_threshold)
	captain.take_damage(1, captain.stagger_threshold)
	captain.update_ai(target, 0.2)
	_expect(captain._stunned_until_ms > Time.get_ticks_msec())
	_expect(captain.stagger == 0.0)
	var health_before_window: int = captain.health_current
	captain.take_damage(20)
	_expect(health_before_window - captain.health_current == 25)
	var treant = BossController.new()
	treant.configure_boss(EnemyCatalog.get_definition(&"ancient_treant"), &"ancient_treant", target, null, manager)
	root.add_child(treant)
	treant._rng.seed = 31
	treant.health_current = int(treant.health_maximum * 0.55)
	treant._update_phase()
	_expect(treant.phase == 2)
	var has_cluster := false
	for index in range(80):
		treant._begin_attack(target)
		if treant.telegraph_kind == "root_cluster":
			has_cluster = true
			break
	_expect(has_cluster)
	treant.telegraph_center = Vector2(200, 200)
	treant.telegraph_direction = Vector2.RIGHT
	target.global_position = treant._root_cluster_center(-1)
	treant.telegraph_kind = "root_cluster"
	treant._resolve_attack(target)
	_expect(target.damage_received > 0)
	var damage_after_hit: int = target.damage_received
	target.global_position = Vector2(320, 200)
	treant.telegraph_kind = "root_cluster"
	treant._resolve_attack(target)
	_expect(target.damage_received == damage_after_hit)
	treant.health_current = int(treant.health_maximum * 0.20)
	treant._update_phase()
	_expect(treant.phase == 3)
	captain.queue_free()
	treant.queue_free()
	manager.queue_free()
	target.queue_free()


func _test_normal_enemy_health_bar_tracks_authoritative_health() -> void:
	var scene_path := "res://scenes/enemies/common_enemy.tscn"
	if not ResourceLoader.exists(scene_path):
		_expect(false, "normal enemy scene and health bar exist")
		return
	var enemy: EnemyController = load(scene_path).instantiate()
	enemy.configure(EnemyCatalog.get_definition(&"slime"), null, null, null, 2)
	root.add_child(enemy)
	var display: Control = enemy.get_node_or_null("HealthBar")
	if not _expect(display != null, "enemy has an editor-authored health bar"):
		enemy.queue_free()
		return
	var bar: ProgressBar = display.get_node_or_null("Bar")
	if not _expect(bar != null, "health display has a ProgressBar"):
		enemy.queue_free()
		return
	_expect(not display.visible, "full-health enemy bar begins hidden")
	enemy.take_damage(7)
	_expect(display.visible, "damage shows the enemy bar immediately")
	_expect(int(bar.max_value) == enemy.health_maximum, "bar uses scaled authoritative maximum")
	_expect(int(bar.value) == enemy.health_current, "bar uses authoritative current health")
	enemy.take_damage(enemy.health_current)
	_expect(not display.visible, "death hides the enemy bar immediately")
	enemy.queue_free()


func _test_editor_authored_ui_layouts() -> void:
	var layouts := [
		{"path": "res://scenes/ui/save_select.tscn", "nodes": ["Background", "Center/Frame/NameRow/NameInput", "Center/Frame/SlotCards/Slot1/Content/ActionButton"]},
		{"path": "res://scenes/ui/hud.tscn", "nodes": ["Screen/StatusPanel/Stats/HpBar", "Screen/BossPanel/Content/Health", "Screen/InventoryPanel", "Screen/PauseMenu", "Screen/DebugOverlay"]},
		{"path": "res://scenes/ui/inventory_panel.tscn", "nodes": ["Frame/Columns/Pack/Items", "Frame/Columns/MapColumn/MapPanel"]},
		{"path": "res://scenes/ui/pause_menu.tscn", "nodes": ["Frame/Buttons/QuitButton"]},
		{"path": "res://scenes/ui/debug_overlay.tscn", "nodes": ["Panel/Label"]},
	]
	for layout in layouts:
		var path: String = layout["path"]
		if not ResourceLoader.exists(path):
			_expect(false, "editor-authored UI scene exists: " + path)
			continue
		var scene: PackedScene = load(path)
		var instance := scene.instantiate()
		for node_path in layout["nodes"]:
			_expect(instance.get_node_or_null(NodePath(node_path)) != null, "UI node is editable: %s/%s" % [path, node_path])
		instance.free()


func _test_editor_authored_maps() -> void:
	for map_path in ["res://scenes/world/village_world.tscn", "res://scenes/world/green_plains_world.tscn"]:
		var scene: PackedScene = load(map_path)
		var map: Node2D = scene.instantiate()
		var ground := map.get_node_or_null("GroundTiles") as TileMapLayer
		_expect(ground != null and ground.tile_set != null and ground.get_used_cells().size() > 0, "map has paintable editor tiles: " + map_path)
		_expect(map.get_node_or_null("PlayerSpawn") is Marker2D, "map has movable player spawn: " + map_path)
		_expect(map.get_node_or_null("PlacedInteractables") != null, "map has placed interactions: " + map_path)
		if map_path.contains("green_plains"):
			var spawns := map.get_node_or_null("EnemySpawns")
			_expect(spawns != null and spawns.get_child_count() >= 9, "Green Plains has editable enemy spawn markers")
		map.free()


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
