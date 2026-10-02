extends Control
class_name MapPanel

var player: PlayerController
var world: WorldBase
var _path_cells: Array[Vector2i] = []
var _clearing_cells: Array[Vector2i] = []
@onready var _refresh_timer: Timer = $RefreshTimer


func configure(owner: PlayerController, game_world: WorldBase) -> void:
	player = owner
	world = game_world
	_path_cells.clear()
	_clearing_cells.clear()
	for cell in world.tile_layer.get_used_cells():
		var tile := world.tile_layer.get_cell_atlas_coords(cell).x
		if tile == 2:
			_path_cells.append(cell)
		elif tile == 3:
			_clearing_cells.append(cell)


func _ready() -> void:
	_refresh_timer.timeout.connect(queue_redraw)


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
	var mini_tile_size := inner.size / Vector2(world.tile_layer.get_used_rect().size)
	for cell in _path_cells:
		draw_rect(Rect2(inner.position + Vector2(cell) * mini_tile_size, mini_tile_size), Color("c2a06e"))
	for cell in _clearing_cells:
		draw_rect(Rect2(inner.position + Vector2(cell) * mini_tile_size, mini_tile_size), Color("86b36a"))
	for interactable in world.interactables:
		match interactable.kind:
			&"quest_npc": _draw_marker(interactable.global_position, inner, Color("81c9dc"), "!")
			&"waypoint": _draw_marker(interactable.global_position, inner, Color("a8a3ec"), "W")
			&"chest": _draw_marker(interactable.global_position, inner, Color("dea65d"), "*")
	if world.has_node("EnemySpawns"):
		for marker in world.get_node("EnemySpawns").get_children():
			if marker.enemy_id == &"goblin_captain":
				_draw_marker(marker.global_position, inner, Color("c76659"), "C")
			elif marker.enemy_id == &"ancient_treant":
				_draw_marker(marker.global_position, inner, Color("e2c981"), "T")
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
