extends Node2D
class_name WorldBase

const WorldChunk = preload("res://scripts/world/world_chunk.gd")
const Interactable = preload("res://scripts/world/interactable.gd")
const LootPickup = preload("res://scripts/world/loot_pickup.gd")
const WaypointManager = preload("res://scripts/world/waypoint_manager.gd")
const ProjectilePool = preload("res://scripts/combat/projectile_pool.gd")
const EnemyManager = preload("res://scripts/enemies/enemy_activation_manager.gd")
const EnemyController = preload("res://scripts/enemies/enemy_controller.gd")
const BossController = preload("res://scripts/enemies/boss_controller.gd")
const EnemyCatalog = preload("res://scripts/enemies/enemy_catalog.gd")
const PlayerController = preload("res://scripts/player/player_controller.gd")
const LootService = preload("res://scripts/loot/loot_service.gd")
const QuestCatalog = preload("res://scripts/quests/quest_catalog.gd")

const MAP_CHUNK_SIZE := 512.0
const TILE_SIZE := 32
const PUZZLE_SEQUENCE: Array[StringName] = [&"dawn", &"sun", &"leaf"]

var map_id := "village"
var map_size := Vector2i(1024, 768)
var profile
var player: PlayerController
var projectile_pool: ProjectilePool
var enemy_manager: EnemyManager
var waypoint_manager: WaypointManager
var hud
@onready var tile_layer: TileMapLayer = $GroundTiles
@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var placed_interactables: Node2D = $PlacedInteractables
var interactables: Array[Interactable] = []
var bosses: Array[BossController] = []
var chunks: Dictionary = {}
var _nearest_interactable: Interactable
var _interaction_clock := 0.0
var _chunk_cell := Vector2i(-999, -999)
var _boss_ui_clock := 0.0
var _respawning := false
var _rng := RandomNumberGenerator.new()
var _fade_overlay: ColorRect


func _ready() -> void:
	_rng.randomize()
	profile = GameSession.current_profile
	if profile == null:
		call_deferred("_return_to_slot_select")
		return
	if profile.hp <= 0:
		profile.hp = profile.max_hp
	_configure_map()
	map_size = tile_layer.get_used_rect().size * TILE_SIZE
	_create_chunks()
	_populate_environment()
	_register_placed_interactables()
	_create_gameplay_services()
	_spawn_player()
	if map_id == "green_plains":
		GameSession.quest_tracker.enter_plains()
	profile.current_map = map_id
	GameSession.save_progress()
	_populate_content()
	_create_hud()
	_create_fade_overlay()
	_refresh_chunk_activity(true)


func _process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return
	_interaction_clock += delta
	_boss_ui_clock += delta
	if _interaction_clock >= 0.12:
		_interaction_clock = 0.0
		_update_nearest_interactable()
	if _boss_ui_clock >= 0.2:
		_boss_ui_clock = 0.0
		_update_boss_ui()
	if Input.is_action_just_pressed("interact"):
		_interact()
	if Input.is_action_just_pressed("inventory") and hud != null:
		hud.toggle_inventory()
	if Input.is_action_just_pressed("pause") and hud != null:
		hud.toggle_pause()
	if OS.is_debug_build() and Input.is_action_just_pressed("debug_overlay") and hud != null:
		hud.toggle_debug_overlay()
	_refresh_chunk_activity()


func _configure_map() -> void:
	pass


func _populate_environment() -> void:
	pass


func _populate_content() -> void:
	pass


func _register_placed_interactables() -> void:
	for node in placed_interactables.get_children():
		var interactable := node as Interactable
		if interactable == null:
			continue
		if interactable.kind == &"chest" and profile.opened_chests.has(String(interactable.interactable_id)):
			interactable.data["opened"] = true
			interactable.display_name = "Opened chest"
			interactable.queue_redraw()
		interactables.append(interactable)
		interactable.reparent(_chunk_at(interactable.global_position), true)


func find_interactable(interactable_id: StringName) -> Interactable:
	for interactable in interactables:
		if interactable.interactable_id == interactable_id:
			return interactable
	return null


func _create_chunks() -> void:
	var count_x := ceili(float(map_size.x) / MAP_CHUNK_SIZE)
	var count_y := ceili(float(map_size.y) / MAP_CHUNK_SIZE)
	for y in range(count_y):
		for x in range(count_x):
			var chunk := WorldChunk.new()
			chunk.name = "WorldChunk_%d_%d" % [x, y]
			var rect := Rect2(Vector2(x, y) * MAP_CHUNK_SIZE, Vector2.ONE * MAP_CHUNK_SIZE)
			chunk.configure(Vector2i(x, y), rect)
			chunks[Vector2i(x, y)] = chunk
			add_child(chunk)


func _create_gameplay_services() -> void:
	projectile_pool = ProjectilePool.new()
	projectile_pool.name = "ProjectilePool"
	add_child(projectile_pool)
	enemy_manager = EnemyManager.new()
	enemy_manager.name = "EnemyActivationManager"
	add_child(enemy_manager)
	waypoint_manager = WaypointManager.new()
	waypoint_manager.name = "WaypointManager"
	add_child(waypoint_manager)


func _spawn_player() -> void:
	player = PlayerController.new()
	player.name = "Player"
	player.configure(profile, self, enemy_manager, projectile_pool)
	var saved_waypoint := find_interactable(StringName(profile.last_waypoint))
	player.position = saved_waypoint.global_position if saved_waypoint != null and profile.activated_waypoints.has(profile.last_waypoint) else player_spawn.global_position
	player.defeated.connect(_on_player_defeated)
	player.stats_changed.connect(_on_player_stats_changed)
	player.inventory_changed.connect(_on_inventory_changed)
	add_child(player)
	var camera := Camera2D.new()
	camera.name = "Camera2D"
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.0
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = map_size.x
	camera.limit_bottom = map_size.y
	camera.enabled = true
	player.add_child(camera)
	enemy_manager.configure(player)
	waypoint_manager.configure(player, profile, self)


func _create_hud() -> void:
	hud = preload("res://scenes/ui/hud.tscn").instantiate()
	hud.configure(player, self)
	add_child(hud)
	GameSession.message_requested.connect(hud.show_message)


func _create_fade_overlay() -> void:
	var layer := preload("res://scenes/ui/death_fade.tscn").instantiate()
	add_child(layer)
	_fade_overlay = layer.get_node("Fade")


func _refresh_chunk_activity(force: bool = false) -> void:
	if player == null or not is_instance_valid(player):
		return
	var cell := Vector2i(floori(player.global_position.x / MAP_CHUNK_SIZE), floori(player.global_position.y / MAP_CHUNK_SIZE))
	if not force and cell == _chunk_cell:
		return
	_chunk_cell = cell
	var activation_distance_squared := 720.0 * 720.0
	for chunk: WorldChunk in chunks.values():
		chunk.set_active(chunk.distance_squared_to(player.global_position) <= activation_distance_squared)
	enemy_manager.refresh_activity(true)


func add_obstacle(position: Vector2, size: Vector2, node_name: String = "Obstacle") -> StaticBody2D:
	var body := StaticBody2D.new()
	body.name = node_name
	body.collision_layer = 1 << 4
	body.collision_mask = 0
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	body.position = position
	add_child(body)
	return body


func add_world_bounds() -> void:
	add_obstacle(Vector2(map_size.x * 0.5, -24), Vector2(map_size.x, 48), "NorthBounds")
	add_obstacle(Vector2(map_size.x * 0.5, map_size.y + 24), Vector2(map_size.x, 48), "SouthBounds")
	add_obstacle(Vector2(-24, map_size.y * 0.5), Vector2(48, map_size.y), "WestBounds")
	add_obstacle(Vector2(map_size.x + 24, map_size.y * 0.5), Vector2(48, map_size.y), "EastBounds")


func spawn_enemy(enemy_id: StringName, position: Vector2) -> EnemyController:
	var definition := EnemyCatalog.get_definition(enemy_id)
	var actor_scene := EnemyCatalog.get_scene(enemy_id)
	if definition == null or actor_scene == null:
		return null
	var is_boss := enemy_id == &"goblin_captain" or enemy_id == &"ancient_treant"
	if is_boss and profile.defeated_bosses.has(String(enemy_id)):
		return null
	var enemy := actor_scene.instantiate() as EnemyController
	if is_boss:
		var boss := enemy as BossController
		boss.configure_boss(definition, enemy_id, player, projectile_pool, enemy_manager, GameSession.player_count)
		boss.summon_requested.connect(_on_boss_summon_requested)
		boss.boss_defeated.connect(_on_boss_defeated)
		bosses.append(boss)
	else:
		enemy.configure(definition, player, projectile_pool, enemy_manager, GameSession.player_count)
	enemy.name = "Enemy_%s_%d" % [enemy_id, randi()]
	_chunk_at(position).add_child(enemy)
	enemy.global_position = position
	enemy.died.connect(_on_enemy_died)
	enemy_manager.register_enemy(enemy)
	return enemy


func spawn_pickup(category: StringName, item_id: StringName, amount: int, position: Vector2) -> void:
	var pickup := LootPickup.new()
	pickup.name = "Pickup_%s" % item_id
	pickup.configure(category, item_id, amount)
	pickup.position = position
	add_child.call_deferred(pickup)


func _update_nearest_interactable() -> void:
	var closest: Interactable
	var closest_distance := 60.0 * 60.0
	for interactable in interactables:
		if not is_instance_valid(interactable) or not interactable.enabled:
			continue
		var distance_squared := interactable.global_position.distance_squared_to(player.global_position)
		if distance_squared <= closest_distance:
			closest = interactable
			closest_distance = distance_squared
	if closest != _nearest_interactable:
		_nearest_interactable = closest
		if hud != null:
			hud.set_interaction_prompt("F  %s" % closest.display_name if closest != null else "")


func _interact() -> void:
	if _nearest_interactable == null or not is_instance_valid(_nearest_interactable):
		return
	match _nearest_interactable.kind:
		&"quest_npc":
			_interact_quest_npc()
		&"waypoint":
			var waypoint_id := String(_nearest_interactable.interactable_id)
			var was_activated: bool = profile.activated_waypoints.has(waypoint_id)
			waypoint_manager.use_waypoint(waypoint_id)
			GameSession.request_message("Waypoint %s. Health restored." % ("activated" if not was_activated else "ready"))
		&"travel":
			var target_map := str(_nearest_interactable.data.get("map_id", "village"))
			GameSession.travel_to(target_map)
		&"chest":
			_open_chest(String(_nearest_interactable.interactable_id))
		&"rune":
			_press_rune(StringName(str(_nearest_interactable.data.get("symbol", ""))))
		&"hint":
			GameSession.request_message(_nearest_interactable.display_name)
		_:
			_handle_map_interaction(_nearest_interactable)


func _interact_quest_npc() -> void:
	var quest = GameSession.quest_tracker
	var quest_id := String(QuestCatalog.TROUBLE_IN_GREEN_PLAINS.quest_id)
	if quest.completed or profile.completed_quests.has(quest_id):
		GameSession.request_message("The Green Plains trail is clear. Thank you, Wayfarer.")
		return
	if not quest.accepted:
		quest.accept()
		GameSession.request_message("Quest accepted: Trouble in Green Plains. %s" % quest.objective())
		return
	if quest.can_turn_in() and quest.turn_in():
		profile.completed_quests.append(quest_id)
		var quest_definition = QuestCatalog.get_definition(StringName(quest_id))
		profile.gold += quest_definition.reward_gold
		GameSession.add_experience(quest_definition.reward_experience)
		GameSession.request_message("Quest complete. You received %d gold and %d EXP." % [quest_definition.reward_gold, quest_definition.reward_experience])
		GameSession.save_progress(true)
		return
	GameSession.request_message(quest.objective())


func _open_chest(chest_id: String) -> void:
	if profile.opened_chests.has(chest_id):
		GameSession.request_message("The chest is empty.")
		return
	profile.opened_chests.append(chest_id)
	profile.gold += 35
	spawn_pickup(&"materials", &"sunleaf", 4, _nearest_interactable.global_position + Vector2(20, 0))
	GameSession.save_progress()
	GameSession.profile_changed.emit()
	GameSession.request_message("Treasure found: 35 gold and 4 Sunleaf.")


func _press_rune(symbol: StringName) -> void:
	if bool(profile.puzzle_state.get("plains_runes_solved", false)):
		GameSession.request_message("The three stones glow in harmony.")
		return
	var index := int(profile.puzzle_state.get("plains_runes_step", 0))
	if index < PUZZLE_SEQUENCE.size() and symbol == PUZZLE_SEQUENCE[index]:
		index += 1
		profile.puzzle_state["plains_runes_step"] = index
		if index == PUZZLE_SEQUENCE.size():
			profile.puzzle_state["plains_runes_solved"] = true
			_on_puzzle_solved()
			GameSession.request_message("The hidden bramble path opens.")
		else:
			GameSession.request_message("The stone chimes. %d of 3." % index)
	else:
		profile.puzzle_state["plains_runes_step"] = 0
		GameSession.request_message("The sequence fades. Read the trail marker and try again.")
	GameSession.save_progress()


func _on_puzzle_solved() -> void:
	pass


func _handle_map_interaction(_interactable: Interactable) -> void:
	pass


func _on_enemy_died(enemy: EnemyController) -> void:
	if not is_instance_valid(enemy) or enemy.definition == null:
		return
	GameSession.add_experience(enemy.definition.xp_reward)
	var gold := LootService.gold_amount(enemy.definition.gold_min, enemy.definition.gold_max, _rng)
	spawn_pickup(&"gold", &"gold", gold, enemy.global_position + Vector2(-9, 4))
	var drop_index := 0
	for drop in LootService.roll_drops(enemy.definition.loot_table, _rng):
		var category := StringName(str(drop.get("category", "materials")))
		var item_id := StringName(str(drop.get("item_id", "moss_fragment")))
		var amount := maxi(1, int(drop.get("count", 1)))
		spawn_pickup(category, item_id, amount, enemy.global_position + Vector2(10 + drop_index * 18, -4))
		drop_index += 1
	if enemy is BossController:
		GameSession.quest_tracker.defeat_boss(String(enemy.boss_id))
		profile.defeated_bosses.append(String(enemy.boss_id))
	else:
		GameSession.quest_tracker.record_kill()
	GameSession.save_progress()


func _on_boss_defeated(_boss_id: StringName) -> void:
	GameSession.request_message("Boss defeated! Collect the reward and keep exploring.")


func _on_boss_summon_requested(position: Vector2, count: int) -> void:
	for index in range(count):
		spawn_enemy(&"slime", position + Vector2(index * 30, 0))


func _update_boss_ui() -> void:
	if hud == null:
		return
	var nearest_boss: BossController
	var best_distance := 700.0 * 700.0
	for boss in bosses:
		if not is_instance_valid(boss) or boss.is_dead:
			continue
		var distance := boss.global_position.distance_squared_to(player.global_position)
		if distance < best_distance:
			best_distance = distance
			nearest_boss = boss
	hud.bind_boss(nearest_boss)


func _on_player_stats_changed() -> void:
	if hud != null:
		hud.refresh_stats()


func _on_inventory_changed() -> void:
	if hud != null:
		hud.refresh_inventory()


func _on_player_defeated() -> void:
	if _respawning:
		return
	_respawning = true
	player.set_physics_process(false)
	_fade_overlay.color.a = 0.0
	var tween := create_tween()
	tween.tween_property(_fade_overlay, "color:a", 1.0, 0.32)
	tween.tween_interval(0.25)
	tween.tween_callback(_respawn_at_waypoint)


func _respawn_at_waypoint() -> void:
	var spawn: Dictionary = waypoint_manager.respawn_waypoint(map_id, player.global_position)
	profile.current_map = str(spawn.map)
	profile.last_waypoint = str(spawn.get("id", profile.last_waypoint))
	profile.hp = profile.max_hp
	GameSession.save_progress(true)
	if profile.current_map == map_id:
		get_tree().reload_current_scene()
	else:
		get_tree().change_scene_to_file("res://scenes/world/%s_world.tscn" % profile.current_map)


func _chunk_at(position: Vector2) -> WorldChunk:
	var coord := Vector2i(
		clampi(floori(position.x / MAP_CHUNK_SIZE), 0, ceili(float(map_size.x) / MAP_CHUNK_SIZE) - 1),
		clampi(floori(position.y / MAP_CHUNK_SIZE), 0, ceili(float(map_size.y) / MAP_CHUNK_SIZE) - 1)
	)
	return chunks[coord]


func _return_to_slot_select() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/save_select.tscn")
