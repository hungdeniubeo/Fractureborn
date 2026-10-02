extends WorldBase
class_name GreenPlainsWorld

@onready var _hidden_brush_gate: StaticBody2D = $StaticProps/HiddenBrambleGate


func _configure_map() -> void:
	map_id = "green_plains"


func _populate_environment() -> void:
	add_world_bounds()
	if bool(profile.puzzle_state.get("plains_runes_solved", false)):
		_hide_brush_gate()


func _populate_content() -> void:
	for marker in $EnemySpawns.get_children():
		spawn_enemy(marker.enemy_id, marker.global_position)


func _on_puzzle_solved() -> void:
	_hide_brush_gate()


func _hide_brush_gate() -> void:
	if is_instance_valid(_hidden_brush_gate):
		_hidden_brush_gate.queue_free()
	_hidden_brush_gate = null
