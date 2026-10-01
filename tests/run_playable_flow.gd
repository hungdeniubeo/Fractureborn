extends SceneTree

const TEST_SLOT := 3
const TEST_NAME := "FlowTestHuman"
const SAVE_SCENE := "res://scenes/ui/save_select.tscn"

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if OS.get_cmdline_user_args().has("reopen"):
		await _verify_reopen()
	else:
		await _play_flow()
	if _failed:
		quit(1)
	else:
		print("Fractureborn playable flow passed.")
		quit(0)


func _check(condition: bool, description: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("FLOW FAIL: " + description)
	return false


func _load_scene(path: String) -> Node:
	var result := change_scene_to_file(path)
	if not _check(result == OK, "load scene " + path):
		return null
	await process_frame
	await process_frame
	return current_scene


func _press_for(action: String, seconds: float = 0.05) -> void:
	Input.action_press(action)
	await create_timer(seconds).timeout
	Input.action_release(action)
	await process_frame


func _play_flow() -> void:
	var save_service := root.get_node("SaveService")
	save_service.save_directory = "user://tests/flow_characters"
	if save_service.has_slot(TEST_SLOT):
		var old_profile = save_service.load_slot(TEST_SLOT)
		if not _check(old_profile != null and old_profile.character_name == TEST_NAME, "isolated test slot belongs to the flow test"):
			return
	var select = await _load_scene(SAVE_SCENE)
	if not _check(select != null, "save selection opens"):
		return
	select._name_input.text = TEST_NAME
	select._create_slot(TEST_SLOT)
	await process_frame
	await process_frame
	var village = current_scene
	if not _check(village != null and village.map_id == "village" and village.player != null, "Human spawns in Central Village"):
		return
	var player = village.player
	_check(player.get_node("Camera2D").limit_right == village.map_size.x, "village camera stays inside the map")
	var start_x: float = player.global_position.x
	Input.action_press("move_right")
	for index in range(8):
		await physics_frame
	Input.action_release("move_right")
	_check(player.global_position.x > start_x + 3.0, "WASD moves the player")
	player.global_position = Vector2(382, 338)
	village._update_nearest_interactable()
	await _press_for("interact")
	_check(root.get_node("GameSession").quest_tracker.accepted, "village NPC accepts quest")
	player.global_position = Vector2(874, 383)
	village._update_nearest_interactable()
	village._interact()
	await process_frame
	await process_frame
	var plains = current_scene
	if not _check(plains != null and plains.map_id == "green_plains" and plains.player != null, "gate enters Green Plains"):
		return
	player = plains.player
	_check(player.get_node("Camera2D").limit_right == plains.map_size.x, "Plains camera stays inside the map")
	var manager = plains.enemy_manager
	_check(manager.enemies.size() >= 9, "Green Plains enemies and bosses spawn")
	await _press_for("weapon_2")
	_check(plains.profile.equipped_weapon == &"wooden_bow", "2 switches to the bow")
	await _press_for("weapon_1")
	_check(plains.profile.equipped_weapon == &"training_sword", "1 switches to the sword")
	await _press_for("inventory")
	_check(plains.hud._inventory_panel.visible, "Tab opens inventory and map")
	await _press_for("inventory")
	_check(not plains.hud._inventory_panel.visible, "Tab closes inventory and map")
	await _press_for("pause")
	_check(plains.hud._pause_menu.visible, "Esc pauses the game")
	plains.hud._pause_menu._resume()
	var slime = _find_enemy(plains, &"slime")
	if not _check(slime != null, "Slime exists"):
		return
	player.global_position = slime.global_position - Vector2(26, 0)
	manager.refresh_activity(true)
	Input.action_press("aim_right")
	await _press_for("attack")
	Input.action_release("aim_right")
	_check(slime.health_current < slime.health_maximum, "left mouse attack damages a target")
	await _press_for("dodge")
	_check(player.dodge.cooldown_remaining() > 0.0 and player.dodge.is_invulnerable(), "dodge cooldown and invulnerability")
	await _press_for("skill_1")
	await _press_for("skill_2")
	await _press_for("skill_3")
	_check(player.skills.cooldown_remaining(0) > 0.0 and player.skills.cooldown_remaining(1) > 0.0 and player.skills.cooldown_remaining(2) > 0.0, "all skill cooldowns run")
	_check(player.combat_effects().attack_speed > 1.0 and player.movement_speed_multiplier() > 1.0, "skill buffs change combat")
	player.dodge.advance(10.0)
	var ranged_target = _find_enemy(plains, &"goblin_archer")
	if _check(ranged_target != null, "ranged target exists"):
		player.global_position = ranged_target.global_position - Vector2(70, 0)
		manager.refresh_activity(true)
		_check(plains.projectile_pool.fire(ranged_target.global_position - Vector2(48, 0), Vector2.RIGHT, "player", 999, 500.0, 180.0, 0.0, 0.0), "pooled projectile launches")
		for index in range(10):
			await physics_frame
		_check(not is_instance_valid(ranged_target) or ranged_target.is_dead, "projectile collision defeats an enemy")
	for enemy_id in [&"slime", &"slime", &"goblin", &"goblin", &"goblin_archer"]:
		var enemy = _find_enemy(plains, enemy_id)
		if enemy == null:
			continue
		_kill_with_sword(plains, enemy)
	await process_frame
	_check(root.get_node("GameSession").quest_tracker.kill_count >= 5, "enemy deaths advance quest")
	_check(plains.profile.level >= 2, "enemy EXP levels the character")
	var pickups_before: int = get_nodes_in_group("loot_pickups").size()
	_check(pickups_before > 0, "enemies drop loot")
	await _collect_pickups(plains)
	_check(plains.profile.gold > 0, "gold pickup is collected")
	player.global_position = Vector2(500, 580)
	plains._update_nearest_interactable()
	await _press_for("interact")
	_check(plains.profile.activated_waypoints.has("plains_beacon"), "Green Plains waypoint activates")
	for rune_position in [Vector2(670, 425), Vector2(719, 425), Vector2(768, 425)]:
		player.global_position = rune_position
		plains._refresh_chunk_activity(true)
		plains._update_nearest_interactable()
		plains._interact()
	_check(bool(plains.profile.puzzle_state.get("plains_runes_solved", false)), "rune puzzle opens the hidden path")
	player.global_position = Vector2(900, 282)
	plains._refresh_chunk_activity(true)
	plains._update_nearest_interactable()
	plains._interact()
	_check(plains.profile.opened_chests.has("plains_treasure"), "hidden treasure chest opens")
	player.take_damage(35)
	var hurt_hp: int = player.health.current
	var potions_before: int = int(plains.profile.inventory.consumables.health_potion)
	await _press_for("quick_heal")
	_check(player.health.current > hurt_hp and int(plains.profile.inventory.consumables.health_potion) == potions_before - 1, "potion heals and decreases quantity")
	player.take_damage(9999)
	_check(plains._respawning, "death starts respawn sequence")
	await create_timer(0.75).timeout
	await process_frame
	await process_frame
	plains = current_scene
	if not _check(plains != null and plains.map_id == "green_plains" and plains.player != null, "death reloads Green Plains"):
		return
	player = plains.player
	_check(player.global_position.distance_to(Vector2(500, 580)) < 36.0, "respawn uses activated waypoint")
	_check(plains.profile.level >= 2 and plains.profile.gold > 0 and plains.profile.activated_waypoints.has("plains_beacon") and plains.profile.opened_chests.has("plains_treasure"), "death preserves progression")
	var captain = _find_enemy(plains, &"goblin_captain")
	if not _check(captain != null and captain.health_current == captain.health_maximum, "Captain resets at full HP"):
		return
	_kill_with_sword(plains, captain)
	_check(plains.profile.defeated_bosses.has("goblin_captain"), "Captain defeat is recorded")
	var treant = _find_enemy(plains, &"ancient_treant")
	if not _check(treant != null and treant.health_current == treant.health_maximum, "Ancient Treant spawns at full HP"):
		return
	_kill_with_sword(plains, treant)
	_check(plains.profile.defeated_bosses.has("ancient_treant"), "Treant defeat is recorded")
	await process_frame
	_check(get_nodes_in_group("loot_pickups").size() > 0, "boss reward drops")
	await _collect_pickups(plains)
	await _press_for("weapon_2")
	plains.player.global_position = Vector2(64, 590)
	plains._refresh_chunk_activity(true)
	plains._update_nearest_interactable()
	plains._interact()
	await process_frame
	await process_frame
	village = current_scene
	if not _check(village != null and village.map_id == "village", "return gate reaches village"):
		return
	village.player.global_position = Vector2(382, 338)
	village._update_nearest_interactable()
	village._interact()
	_check(village.profile.completed_quests.has("trouble_in_green_plains"), "quest reward is granted")
	root.get_node("GameSession").save_progress(true)
	_check(save_service.has_slot(TEST_SLOT), "completed character is saved")
	print("Fractureborn play phase passed; reopen with -- reopen.")


func _verify_reopen() -> void:
	var save_service := root.get_node("SaveService")
	save_service.save_directory = "user://tests/flow_characters"
	var saved = save_service.load_slot(TEST_SLOT)
	if not _check(saved != null and saved.character_name == TEST_NAME, "saved character loads in a new process"):
		return
	var select = await _load_scene(SAVE_SCENE)
	if not _check(select != null, "save selection opens on reopen"):
		return
	select._load_slot(TEST_SLOT)
	await process_frame
	await process_frame
	var world = current_scene
	if not _check(world != null and world.player != null, "continue enters saved world"):
		return
	_check(world.profile.level >= 2 and world.profile.gold > 0, "level and gold persist")
	_check(world.profile.activated_waypoints.has("plains_beacon"), "waypoint persists")
	_check(world.profile.defeated_bosses.has("goblin_captain") and world.profile.defeated_bosses.has("ancient_treant"), "boss progress persists")
	_check(world.profile.completed_quests.has("trouble_in_green_plains"), "quest completion persists")
	_check(world.profile.inventory.has("consumables"), "inventory persists")
	_check(world.profile.equipped_weapon == &"wooden_bow" and world.player.weapons.current_weapon.weapon_id == &"wooden_bow", "equipped weapon persists")
	_check(world.profile.opened_chests.has("plains_treasure") and bool(world.profile.puzzle_state.get("plains_runes_solved", false)), "puzzle and chest persist")


func _find_enemy(world: Node, enemy_id: StringName):
	for enemy in world.enemy_manager.enemies:
		if is_instance_valid(enemy) and not enemy.is_dead and enemy.definition.enemy_id == enemy_id:
			return enemy
	return null


func _kill_with_sword(world: Node, enemy: Node) -> void:
	world.player.global_position = enemy.global_position - Vector2(28, 0)
	world.enemy_manager.refresh_activity(true)
	for index in range(100):
		if enemy.is_dead:
			return
		world.player.weapons.advance(10.0)
		world.player.weapons.attack(Vector2.RIGHT, world.player.combat_effects())
	_check(enemy.is_dead, "weapon can defeat " + String(enemy.definition.enemy_id))


func _collect_pickups(world: Node) -> void:
	for pickup in get_nodes_in_group("loot_pickups"):
		if not is_instance_valid(pickup):
			continue
		world.player.global_position = pickup.global_position
		await physics_frame
		await physics_frame
