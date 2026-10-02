extends RefCounted
class_name QuestTracker

signal changed

const QUEST_ID := "trouble_in_green_plains"
const QuestCatalog = preload("res://scripts/quests/quest_catalog.gd")

var definition: QuestDefinition = QuestCatalog.TROUBLE_IN_GREEN_PLAINS

var accepted := false
var entered_plains := false
var kill_count := 0
var waypoint_activated := false
var defeated_bosses: Dictionary = {}
var completed := false


func accept() -> bool:
	if accepted or completed:
		return false
	accepted = true
	changed.emit()
	return true


func enter_plains() -> void:
	if not entered_plains:
		entered_plains = true
		changed.emit()


func record_kill() -> void:
	if not completed and kill_count < definition.required_kills:
		kill_count += 1
		changed.emit()


func activate_waypoint() -> void:
	if not waypoint_activated:
		waypoint_activated = true
		changed.emit()


func defeat_boss(boss_id: String) -> void:
	if not completed and not defeated_bosses.has(boss_id):
		defeated_bosses[boss_id] = true
		changed.emit()


func can_turn_in() -> bool:
	return accepted and entered_plains and kill_count >= definition.required_kills and waypoint_activated and defeated_bosses.has("goblin_captain") and defeated_bosses.has("ancient_treant") and not completed


func turn_in() -> bool:
	if not can_turn_in():
		return false
	completed = true
	changed.emit()
	return true


func objective() -> String:
	if completed:
		return definition.objective_steps[7]
	if not accepted:
		return definition.objective_steps[0]
	if not entered_plains:
		return definition.objective_steps[1]
	if kill_count < definition.required_kills:
		return "%s (%d/%d)" % [definition.objective_steps[2], kill_count, definition.required_kills]
	if not waypoint_activated:
		return definition.objective_steps[3]
	if not defeated_bosses.has("goblin_captain"):
		return definition.objective_steps[4]
	if not defeated_bosses.has("ancient_treant"):
		return definition.objective_steps[5]
	return definition.objective_steps[6]


func to_dict() -> Dictionary:
	return {
		"quest_id": QUEST_ID,
		"accepted": accepted,
		"entered_plains": entered_plains,
		"kill_count": kill_count,
		"waypoint_activated": waypoint_activated,
		"defeated_bosses": defeated_bosses.duplicate(true),
		"completed": completed,
	}


static func from_dict(data: Dictionary) -> QuestTracker:
	var tracker := QuestTracker.new()
	tracker.accepted = bool(data.get("accepted", false))
	tracker.entered_plains = bool(data.get("entered_plains", false))
	tracker.kill_count = clampi(int(data.get("kill_count", 0)), 0, tracker.definition.required_kills)
	tracker.waypoint_activated = bool(data.get("waypoint_activated", false))
	var bosses: Variant = data.get("defeated_bosses", {})
	tracker.defeated_bosses = bosses.duplicate(true) if bosses is Dictionary else {}
	tracker.completed = bool(data.get("completed", false))
	return tracker
