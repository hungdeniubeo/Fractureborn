extends Node

signal profile_changed
signal inventory_changed
signal quest_changed
signal message_requested(message: String)

const CharacterProfile = preload("res://scripts/save/character_profile.gd")
const QuestTracker = preload("res://scripts/quests/quest_tracker.gd")
const InputActions = preload("res://scripts/core/input_actions.gd")
const PROGRESSION = preload("res://scripts/core/progression.gd")

var current_profile
var active_slot := 0
var quest_tracker
var player_count := 1


func _ready() -> void:
	InputActions.install_defaults()
	get_tree().set_auto_accept_quit(false)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_progress(true)
		get_tree().quit()


func begin_character(slot_index: int, profile) -> void:
	active_slot = slot_index
	current_profile = profile
	quest_tracker = QuestTracker.from_dict(profile.quest_state)
	quest_tracker.changed.connect(_on_quest_changed)
	profile_changed.emit()
	quest_changed.emit()


func save_progress(immediate: bool = false) -> void:
	if current_profile == null or active_slot == 0:
		return
	current_profile.quest_state = quest_tracker.to_dict()
	if immediate:
		SaveService.save_now(active_slot, current_profile)
	else:
		SaveService.request_save(active_slot, current_profile)


func add_experience(amount: int) -> int:
	if current_profile == null:
		return 0
	var levels_gained: int = PROGRESSION.apply_experience(current_profile, amount)
	if levels_gained > 0:
		current_profile.hp = mini(current_profile.max_hp, current_profile.hp)
		request_message("Level %d reached! Max HP and damage increased." % current_profile.level)
	profile_changed.emit()
	save_progress()
	return levels_gained


func request_message(message: String) -> void:
	message_requested.emit(message)


func travel_to(map_id: String) -> void:
	if current_profile == null or not ["village", "green_plains"].has(map_id):
		return
	current_profile.current_map = map_id
	save_progress(true)
	var scene_path := "res://scenes/world/%s_world.tscn" % map_id
	get_tree().change_scene_to_file(scene_path)


func _on_quest_changed() -> void:
	if current_profile != null:
		current_profile.quest_state = quest_tracker.to_dict()
		quest_changed.emit()
		save_progress()
