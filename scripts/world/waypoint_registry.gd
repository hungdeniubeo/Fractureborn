extends RefCounted
class_name WaypointRegistry


static func activate(profile, waypoint_id: String) -> bool:
	if waypoint_id.is_empty() or profile.activated_waypoints.has(waypoint_id):
		return false
	profile.activated_waypoints.append(waypoint_id)
	profile.last_waypoint = waypoint_id
	return true


static func is_activated(profile, waypoint_id: String) -> bool:
	return profile.activated_waypoints.has(waypoint_id)


static func latest(profile) -> String:
	if profile.last_waypoint.is_empty() and not profile.activated_waypoints.is_empty():
		return profile.activated_waypoints.back()
	return str(profile.last_waypoint)
