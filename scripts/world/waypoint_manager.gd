extends Node
class_name WaypointManager

signal activated(waypoint_id: String, is_new: bool)

const WaypointRegistry = preload("res://scripts/world/waypoint_registry.gd")

# Map identity is save data; the actual waypoint positions belong to map scenes.
const WAYPOINT_MAPS := {
	"village_well": "village",
	"plains_beacon": "green_plains",
}

var player: PlayerController
var profile
var world


func configure(owner: PlayerController, character_profile, game_world) -> void:
	player = owner
	profile = character_profile
	world = game_world


func use_waypoint(waypoint_id: String) -> bool:
	if player == null or profile == null or world == null:
		return false
	var placed = world.find_interactable(StringName(waypoint_id))
	if placed == null or placed.kind != &"waypoint":
		return false
	var is_new := WaypointRegistry.activate(profile, waypoint_id)
	player.health.configure(player.health.maximum, player.health.maximum)
	if is_new and waypoint_id == "plains_beacon":
		GameSession.quest_tracker.activate_waypoint()
	GameSession.save_progress(true)
	activated.emit(waypoint_id, is_new)
	return is_new


func respawn_waypoint(map_id: String, position: Vector2) -> Dictionary:
	var selected_id := ""
	var selected_position := Vector2.ZERO
	var best_distance := INF
	for waypoint_id in profile.activated_waypoints:
		if WAYPOINT_MAPS.get(waypoint_id, "") != map_id:
			continue
		var placed = world.find_interactable(StringName(waypoint_id))
		if placed == null:
			continue
		var distance := position.distance_squared_to(placed.global_position)
		if distance < best_distance:
			best_distance = distance
			selected_id = waypoint_id
			selected_position = placed.global_position
	if not selected_id.is_empty():
		return {"id": selected_id, "map": map_id, "position": selected_position}
	selected_id = WaypointRegistry.latest(profile)
	if selected_id.is_empty() or not WAYPOINT_MAPS.has(selected_id):
		selected_id = "village_well"
	return {"id": selected_id, "map": WAYPOINT_MAPS[selected_id]}
