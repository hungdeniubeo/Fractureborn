extends Node
class_name WaypointManager

signal activated(waypoint_id: String, is_new: bool)

const WaypointRegistry = preload("res://scripts/world/waypoint_registry.gd")
const WAYPOINTS := {
	"village_well": {"map": "village", "position": Vector2(324, 420)},
	"plains_beacon": {"map": "green_plains", "position": Vector2(500, 580)},
}

var player: PlayerController
var profile


func configure(owner: PlayerController, character_profile) -> void:
	player = owner
	profile = character_profile


func use_waypoint(waypoint_id: String) -> bool:
	if player == null or profile == null or not WAYPOINTS.has(waypoint_id):
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
	var best_distance := INF
	for waypoint_id in profile.activated_waypoints:
		var waypoint: Dictionary = WAYPOINTS.get(waypoint_id, {})
		if waypoint.get("map", "") != map_id:
			continue
		var distance: float = position.distance_squared_to(waypoint.position)
		if distance < best_distance:
			best_distance = distance
			selected_id = waypoint_id
	if selected_id.is_empty():
		selected_id = WaypointRegistry.latest(profile)
	var result: Dictionary = WAYPOINTS.get(selected_id, {"map": "village", "position": Vector2(324, 420)}).duplicate(true)
	result["id"] = selected_id if not selected_id.is_empty() else "village_well"
	return result
