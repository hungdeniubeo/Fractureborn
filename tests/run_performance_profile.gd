extends SceneTree

const CharacterProfile = preload("res://scripts/save/character_profile.gd")

var _quick := false


func _initialize() -> void:
	_quick = OS.get_cmdline_user_args().has("quick")
	call_deferred("_run")


func _run() -> void:
	await process_frame
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if OS.get_cmdline_user_args().has("windowed") else DisplayServer.WINDOW_MODE_FULLSCREEN)
		DisplayServer.window_set_size(Vector2i(1920, 1080))
	var profile := CharacterProfile.new("Performance Probe")
	profile.max_hp = 100000
	profile.hp = profile.max_hp
	root.get_node("GameSession").begin_character(0, profile)
	change_scene_to_file("res://scenes/world/village_world.tscn")
	await process_frame
	await process_frame
	var world = current_scene
	if world == null or world.player == null:
		push_error("Performance profile could not load Village")
		quit(1)
		return
	print("PROFILE display=", DisplayServer.get_name(), " window=", DisplayServer.window_get_size(), " viewport=", root.size)
	await _sample("village_idle", 2.0 if _quick else 15.0)
	change_scene_to_file("res://scenes/world/green_plains_world.tscn")
	await process_frame
	await process_frame
	world = current_scene
	if world == null or world.player == null:
		push_error("Performance profile could not load Green Plains")
		quit(1)
		return
	world.player.global_position = Vector2(500, 580)
	world._refresh_chunk_activity(true)
	await _sample("plains_exploration", 2.0 if _quick else 15.0)
	world.player.global_position = Vector2(700, 660)
	world._refresh_chunk_activity(true)
	await _sample("several_enemies", 2.0 if _quick else 15.0)
	for index in range(10):
		var angle := TAU * float(index) / 10.0
		world.spawn_enemy(&"goblin", world.player.global_position + Vector2.RIGHT.rotated(angle) * 180.0)
	world.enemy_manager.refresh_activity(true)
	await _sample("phase1_stress", 2.0 if _quick else 20.0)
	world.player.global_position = Vector2(1000, 722)
	world._refresh_chunk_activity(true)
	await _sample("goblin_captain", 2.0 if _quick else 15.0)
	world.player.global_position = Vector2(1450, 835)
	world._refresh_chunk_activity(true)
	await _sample("ancient_treant", 2.0 if _quick else 20.0)
	world.player.weapons.equip(&"basic_pistol")
	for index in range(4):
		world.spawn_enemy(&"goblin_archer", world.player.global_position + Vector2(130, index * 38 - 57))
	world.enemy_manager.refresh_activity(true)
	await _sample("boss_projectiles", 2.0 if _quick else 20.0, true)
	await _sample("repeated_combat", 3.0 if _quick else 180.0, true)
	print("Fractureborn performance profile finished.")
	quit(0)


func _sample(label: String, seconds: float, fire_weapon: bool = false) -> void:
	await create_timer(0.5 if _quick else 30.0).timeout
	var start := Time.get_ticks_msec()
	var samples := 0
	var fps_total := 0.0
	var fps_min := INF
	var process_max := 0.0
	var physics_max := 0.0
	var nodes_max := 0
	var projectiles_max := 0
	var enemies_max := 0
	var memory_start := OS.get_static_memory_usage()
	while Time.get_ticks_msec() - start < int(seconds * 1000.0):
		if fire_weapon and current_scene != null:
			var world = current_scene
			world.player.weapons.attack(Vector2.RIGHT, world.player.combat_effects())
		var fps: float = Performance.get_monitor(Performance.TIME_FPS)
		fps_min = minf(fps_min, fps)
		fps_total += fps
		process_max = maxf(process_max, Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0)
		physics_max = maxf(physics_max, Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0)
		nodes_max = maxi(nodes_max, int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)))
		if current_scene != null:
			projectiles_max = maxi(projectiles_max, current_scene.projectile_pool.active_count)
			enemies_max = maxi(enemies_max, current_scene.enemy_manager.active_enemies.size())
		samples += 1
		await create_timer(0.25).timeout
	var memory_end := OS.get_static_memory_usage()
	print("PROFILE ", JSON.stringify({
		"scenario": label,
		"seconds": seconds,
		"samples": samples,
		"fps_mean": snappedf(fps_total / maxf(1.0, float(samples)), 0.1),
		"fps_min_sample": fps_min,
		"process_ms_max_sample": snappedf(process_max, 0.01),
		"physics_ms_max_sample": snappedf(physics_max, 0.01),
		"nodes_max": nodes_max,
		"active_enemies_max": enemies_max,
		"active_projectiles_max": projectiles_max,
		"static_memory_start_mb": snappedf(float(memory_start) / 1048576.0, 0.1),
		"static_memory_end_mb": snappedf(float(memory_end) / 1048576.0, 0.1),
	}))
