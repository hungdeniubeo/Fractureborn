extends Node

signal save_completed(slot_index: int)
signal save_failed(slot_index: int, error_message: String)

const CharacterProfile = preload("res://scripts/save/character_profile.gd")
const PerformanceSettings = preload("res://scripts/core/performance_settings.gd")
const SLOT_COUNT := 3
const SAVE_DIRECTORY := "user://characters"
const SETTINGS_PATH := "user://settings.json"

var _pending_profiles: Dictionary = {}
var _save_timer: Timer
var performance_settings: PerformanceSettings


func _ready() -> void:
	performance_settings = load_settings()
	performance_settings.apply()
	_save_timer = Timer.new()
	_save_timer.one_shot = true
	_save_timer.wait_time = 0.35
	_save_timer.timeout.connect(_flush_pending)
	add_child(_save_timer)


func request_save(slot_index: int, profile) -> void:
	if not _valid_slot(slot_index) or profile == null:
		return
	_pending_profiles[slot_index] = profile.to_dict()
	_save_timer.start()


func save_now(slot_index: int, profile) -> bool:
	if not _valid_slot(slot_index) or profile == null:
		return false
	_pending_profiles.erase(slot_index)
	var directory_error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SAVE_DIRECTORY))
	if directory_error != OK:
		save_failed.emit(slot_index, "Could not create character save directory.")
		return false
	var file := FileAccess.open(_slot_path(slot_index), FileAccess.WRITE)
	if file == null:
		save_failed.emit(slot_index, "Could not open character save file.")
		return false
	file.store_string(JSON.stringify(profile.to_dict(), "\t"))
	file.flush()
	if file.get_error() != OK:
		save_failed.emit(slot_index, "Could not write character save file.")
		return false
	save_completed.emit(slot_index)
	return true


func load_slot(slot_index: int):
	if not _valid_slot(slot_index) or not FileAccess.file_exists(_slot_path(slot_index)):
		return null
	var file := FileAccess.open(_slot_path(slot_index), FileAccess.READ)
	if file == null:
		return null
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return null
	return CharacterProfile.from_dict(parsed)


func has_slot(slot_index: int) -> bool:
	return _valid_slot(slot_index) and FileAccess.file_exists(_slot_path(slot_index))


func slot_summary(slot_index: int) -> Dictionary:
	if not has_slot(slot_index):
		return {"slot": slot_index, "occupied": false}
	var profile = load_slot(slot_index)
	if profile == null:
		return {"slot": slot_index, "occupied": true, "corrupted": true}
	return {
		"slot": slot_index,
		"occupied": true,
		"character_name": profile.character_name,
		"race_id": String(profile.race_id),
		"level": profile.level,
	}


func load_settings() -> PerformanceSettings:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return PerformanceSettings.new()
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file == null:
		return PerformanceSettings.new()
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return PerformanceSettings.from_dict(parsed) if parsed is Dictionary else PerformanceSettings.new()


func save_settings(settings: PerformanceSettings) -> bool:
	if settings == null:
		return false
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(settings.to_dict(), "\t"))
	file.flush()
	if file.get_error() != OK:
		return false
	performance_settings = settings
	performance_settings.apply()
	return true


func _flush_pending() -> void:
	var pending := _pending_profiles.duplicate(true)
	_pending_profiles.clear()
	for slot_index in pending:
		var profile = CharacterProfile.from_dict(pending[slot_index])
		save_now(int(slot_index), profile)


func _valid_slot(slot_index: int) -> bool:
	return slot_index >= 1 and slot_index <= SLOT_COUNT


func _slot_path(slot_index: int) -> String:
	return "%s/slot_%d.json" % [SAVE_DIRECTORY, slot_index]
