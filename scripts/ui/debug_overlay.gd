extends Control
class_name DebugOverlay

var world: WorldBase
var _label: Label
var _timer: Timer


func configure(game_world: WorldBase) -> void:
	world = game_world


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel := PanelContainer.new()
	panel.position = Vector2(16, 116)
	panel.add_theme_stylebox_override("panel", _panel_style())
	add_child(panel)
	_label = Label.new()
	_label.add_theme_font_size_override("font_size", 13)
	_label.text = "Performance overlay · F3"
	panel.add_child(_label)
	_timer = Timer.new()
	_timer.wait_time = 0.5
	_timer.timeout.connect(_refresh)
	add_child(_timer)


func toggle() -> void:
	if not OS.is_debug_build():
		return
	visible = not visible
	if visible:
		_refresh()
		_timer.start()
	else:
		_timer.stop()


func _refresh() -> void:
	if world == null or _label == null:
		return
	var active_enemies := world.enemy_manager.active_enemies.size()
	var total_enemies := world.enemy_manager.enemies.size()
	var projectiles := world.projectile_pool.active_count
	var allocated_projectiles := world.projectile_pool.total_count()
	var loot_nodes := world.get_tree().get_nodes_in_group("loot_pickups").size()
	var relevant_nodes := total_enemies + allocated_projectiles + world.interactables.size() + loot_nodes + 1
	var process_ms := Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	var physics_ms := Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0
	var memory_mb := float(OS.get_static_memory_usage()) / (1024.0 * 1024.0)
	_label.text = "FPS  %d\nEnemies active  %d / %d\nProjectiles  %d / %d\nGameplay nodes  %d\nProcess  %.2f ms  ·  Physics  %.2f ms\nStatic memory  %.1f MB" % [Engine.get_frames_per_second(), active_enemies, total_enemies, projectiles, allocated_projectiles, relevant_nodes, process_ms, physics_ms, memory_mb]


func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.055, 0.075, 0.93)
	style.border_color = Color("91b7c5")
	style.set_border_width_all(1)
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	return style
