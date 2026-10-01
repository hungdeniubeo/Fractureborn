extends Control
class_name MapPanel

var player: PlayerController
var world: WorldBase
var _refresh_timer: Timer


func configure(owner: PlayerController, game_world: WorldBase) -> void:
	player = owner
	world = game_world


func _ready() -> void:
	custom_minimum_size = Vector2(220, 330)
	_refresh_timer = Timer.new()
	_refresh_timer.wait_time = 0.12
	_refresh_timer.timeout.connect(queue_redraw)
	add_child(_refresh_timer)


func set_tracking_enabled(enabled: bool) -> void:
	if _refresh_timer == null:
		return
	if enabled:
		_refresh_timer.start()
		queue_redraw()
	else:
		_refresh_timer.stop()


func _draw() -> void:
	if world == null or player == null:
		return
	var rect := Rect2(Vector2.ZERO, size)
	draw_rect(rect, Color("1b2a34"))
	draw_rect(rect, Color("607c88"), false, 2.0)
	var inner := Rect2(Vector2(10, 10), size - Vector2(20, 20))
	draw_rect(inner, Color("4e9254"))
	if world.map_id == "green_plains":
		var previous := _map_point(Vector2(0, 588), inner)
		for index in range(1, 24):
			var x := float(world.map_size.x) * float(index) / 23.0
			var y := 18.0 + sin(x * 0.09) * 3.5
			var current := _map_point(Vector2(x, y * 32.0), inner)
			draw_line(previous, current, Color("c2a06e"), 5.0)
			previous = current
		_draw_marker(Vector2(1000, 722), inner, Color("c76659"), "C")
		_draw_marker(Vector2(1450, 835), inner, Color("e2c981"), "T")
		_draw_marker(Vector2(900, 282), inner, Color("dea65d"), "*")
	else:
		draw_line(_map_point(Vector2(220, 384), inner), _map_point(Vector2(930, 384), inner), Color("c2a06e"), 7.0)
		_draw_marker(Vector2(382, 338), inner, Color("81c9dc"), "!")
	_draw_marker(Vector2(500 if world.map_id == "green_plains" else 310, 580 if world.map_id == "green_plains" else 492), inner, Color("a8a3ec"), "W")
	var player_map := _map_point(player.global_position, inner)
	draw_circle(player_map, 6.0, Color.WHITE)
	draw_circle(player_map, 3.0, Color("526fca"))
	draw_string(ThemeDB.fallback_font, Vector2(10, size.y - 4), world.map_id.replace("_", " ").to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("d3e1dc"))


func _draw_marker(world_position: Vector2, rect: Rect2, color: Color, glyph: String) -> void:
	var point := _map_point(world_position, rect)
	draw_circle(point, 5.0, color)
	draw_string(ThemeDB.fallback_font, point + Vector2(-4, 4), glyph, HORIZONTAL_ALIGNMENT_LEFT, 12, 9, Color.WHITE)


func _map_point(world_position: Vector2, rect: Rect2) -> Vector2:
	var normalized := Vector2(world_position.x / float(world.map_size.x), world_position.y / float(world.map_size.y))
	return rect.position + normalized * rect.size
