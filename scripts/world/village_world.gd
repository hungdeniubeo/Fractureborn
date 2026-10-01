extends WorldBase
class_name VillageWorld


func _configure_map() -> void:
	map_id = "village"
	map_size = Vector2i(1024, 768)
	map_theme = &"village"
	spawn_position = Vector2(310, 420)


func _populate_environment() -> void:
	add_world_bounds()
	add_obstacle(Vector2(195, 252), Vector2(166, 92), "CottageCollision")
	add_obstacle(Vector2(635, 256), Vector2(150, 96), "ForgeCollision")
	add_obstacle(Vector2(780, 518), Vector2(130, 88), "MarketCollision")
	add_obstacle(Vector2(170, 620), Vector2(132, 72), "GardenWall")
	add_obstacle(Vector2(816, 130), Vector2(92, 88), "StoreWall")
	decoration_layer.add_tree(Vector2(95, 230), 1.1, 0)
	decoration_layer.add_tree(Vector2(84, 548), 0.9, 1)
	decoration_layer.add_tree(Vector2(520, 130), 1.0, 2)
	decoration_layer.add_tree(Vector2(948, 588), 1.0, 0)
	decoration_layer.add_rock(Vector2(422, 616), 0.8)
	decoration_layer.add_sign(Vector2(628, 229), Color("c58c6b"))
	decoration_layer.add_sign(Vector2(783, 488), Color("d4ad68"))
	decoration_layer.add_sign(Vector2(862, 368), Color("90c9d4"))
	add_interactable(&"village_archivist", "Archivist Edda", &"quest_npc", Vector2(382, 338))
	add_interactable(&"village_well", "Village Waystone", &"waypoint", Vector2(310, 492))
	add_interactable(&"village_gate", "Path to Green Plains", &"travel", Vector2(874, 383), {"map_id": "green_plains"})


func _populate_content() -> void:
	pass


func _tile_at(cell_x: int, cell_y: int) -> int:
	if cell_x >= 8 and cell_x <= 29 and cell_y >= 10 and cell_y <= 13:
		return 2
	if cell_x >= 8 and cell_x <= 10 and cell_y >= 6 and cell_y <= 18:
		return 2
	if cell_x >= 9 and cell_x <= 17 and cell_y >= 9 and cell_y <= 16:
		return 3
	return 1 if (cell_x * 7 + cell_y * 11) % 9 == 0 else 0
