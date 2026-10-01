extends WorldBase
class_name GreenPlainsWorld

var _hidden_brush_gate: StaticBody2D


func _configure_map() -> void:
	map_id = "green_plains"
	map_size = Vector2i(1792, 1280)
	map_theme = &"green_plains"
	spawn_position = Vector2(112, 592)


func _populate_environment() -> void:
	add_world_bounds()
	for point in [Vector2(285, 330), Vector2(400, 306), Vector2(645, 690), Vector2(815, 720), Vector2(1100, 300), Vector2(1220, 1010), Vector2(1540, 510), Vector2(1600, 945)]:
		decoration_layer.add_tree(point, 0.9 + float(int(point.x) % 3) * 0.12, int(point.y) % 3)
		add_obstacle(point + Vector2(0, 10), Vector2(22, 22), "TreeTrunk")
	for point in [Vector2(350, 755), Vector2(616, 352), Vector2(770, 884), Vector2(1010, 428), Vector2(1185, 620), Vector2(1500, 670)]:
		decoration_layer.add_rock(point, 0.8)
		add_obstacle(point + Vector2(0, 5), Vector2(27, 17), "RockCollision")
	add_interactable(&"plains_return_gate", "Return to Central Village", &"travel", Vector2(64, 590), {"map_id": "village"})
	add_interactable(&"plains_beacon", "Green Plains Waystone", &"waypoint", Vector2(500, 580))
	add_interactable(&"plains_treasure", "Tangled Trail Chest", &"chest", Vector2(900, 282))
	add_interactable(&"rune_dawn", "Dawn Stone", &"rune", Vector2(670, 425), {"symbol": "dawn"})
	add_interactable(&"rune_sun", "Sun Stone", &"rune", Vector2(719, 425), {"symbol": "sun"})
	add_interactable(&"rune_leaf", "Leaf Stone", &"rune", Vector2(768, 425), {"symbol": "leaf"})
	add_interactable(&"rune_hint", "Trail Marker: Dawn → Sun → Leaf", &"hint", Vector2(620, 475))
	if not bool(profile.puzzle_state.get("plains_runes_solved", false)):
		_hidden_brush_gate = add_obstacle(Vector2(860, 330), Vector2(104, 40), "HiddenBrambleGate")
		decoration_layer.add_brush_wall(Rect2(Vector2(808, 306), Vector2(104, 40)))


func _populate_content() -> void:
	spawn_enemy(&"slime", Vector2(308, 480))
	spawn_enemy(&"slime", Vector2(378, 390))
	spawn_enemy(&"goblin", Vector2(656, 705))
	spawn_enemy(&"goblin", Vector2(725, 676))
	spawn_enemy(&"goblin_archer", Vector2(820, 650))
	spawn_enemy(&"goblin", Vector2(1120, 470))
	spawn_enemy(&"goblin_archer", Vector2(1176, 430))
	spawn_enemy(&"goblin_captain", Vector2(1000, 722))
	spawn_enemy(&"ancient_treant", Vector2(1450, 835))


func _on_puzzle_solved() -> void:
	if is_instance_valid(_hidden_brush_gate):
		_hidden_brush_gate.queue_free()
	_hidden_brush_gate = null
	decoration_layer.clear_brush_walls()


func _tile_at(cell_x: int, cell_y: int) -> int:
	var path_center := 18 + int(sin(float(cell_x) * 0.09) * 3.5)
	if abs(cell_y - path_center) <= 1:
		return 2
	if cell_x >= 20 and cell_x <= 31 and cell_y >= 9 and cell_y <= 15:
		return 3
	return 1 if (cell_x * 13 + cell_y * 7) % 11 == 0 else 0
