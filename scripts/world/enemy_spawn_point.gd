@tool
extends Marker2D
class_name EnemySpawnPoint

@export var enemy_id: StringName = &"slime"


func _draw() -> void:
	if Engine.is_editor_hint():
		draw_circle(Vector2.ZERO, 10.0, Color(0.88, 0.32, 0.28, 0.55))
		draw_line(Vector2(-13, 0), Vector2(13, 0), Color.WHITE, 2.0)
		draw_line(Vector2(0, -13), Vector2(0, 13), Color.WHITE, 2.0)
