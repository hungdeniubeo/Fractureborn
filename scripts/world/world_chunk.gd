extends Node2D
class_name WorldChunk

var chunk_coord := Vector2i.ZERO
var bounds := Rect2()
var is_active := true


func configure(coord: Vector2i, rect: Rect2) -> void:
	chunk_coord = coord
	bounds = rect


func set_active(active: bool) -> void:
	if is_active == active:
		return
	is_active = active
	for child in get_children():
		if child.has_method("set_active"):
			child.call("set_active", active)
		elif child.has_method("set_world_active"):
			child.call("set_world_active", active)
		else:
			child.visible = active


func distance_squared_to(point: Vector2) -> float:
	var nearest := Vector2(
		clampf(point.x, bounds.position.x, bounds.end.x),
		clampf(point.y, bounds.position.y, bounds.end.y)
	)
	return nearest.distance_squared_to(point)
