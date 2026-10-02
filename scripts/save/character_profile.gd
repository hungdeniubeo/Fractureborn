extends RefCounted
class_name CharacterProfile

const RaceData = preload("res://scripts/core/race_data.gd")
const SAVE_VERSION := 2
const MAX_LEVEL := 50

var character_name := "Wayfarer"
var race_id: StringName = &"HUMAN"
var level := 1
var exp := 0
var gold := 0
var hp := 100
var max_hp := 100
var base_damage := 10
var inventory: Dictionary = {}
var equipped_weapon: StringName = &"training_sword"
var weapon_slots: Dictionary = {"1": "training_sword", "2": "wooden_bow"}
var activated_waypoints: Array[String] = []
var completed_quests: Array[String] = []
var defeated_bosses: Array[String] = []
var opened_chests: Array[String] = []
var puzzle_state: Dictionary = {}
var current_map := "village"
var last_waypoint := "village_well"
var quest_state: Dictionary = {}


func _init(new_name: String = "Wayfarer") -> void:
	character_name = new_name.strip_edges()
	if character_name.is_empty():
		character_name = "Wayfarer"
	inventory = {
		"weapons": {"training_sword": 1, "wooden_bow": 1},
		"materials": {},
		"consumables": {"health_potion": 3},
	}


func to_dict() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"character_name": character_name,
		"race_id": String(race_id),
		"level": level,
		"exp": exp,
		"gold": gold,
		"hp": hp,
		"max_hp": max_hp,
		"base_damage": base_damage,
		"inventory": inventory.duplicate(true),
		"equipped_weapon": String(equipped_weapon),
		"weapon_slots": weapon_slots.duplicate(true),
		"activated_waypoints": activated_waypoints.duplicate(),
		"completed_quests": completed_quests.duplicate(),
		"defeated_bosses": defeated_bosses.duplicate(),
		"opened_chests": opened_chests.duplicate(),
		"puzzle_state": puzzle_state.duplicate(true),
		"current_map": current_map,
		"last_waypoint": last_waypoint,
		"quest_state": quest_state.duplicate(true),
	}


static func from_dict(source: Dictionary) -> CharacterProfile:
	var data := source.duplicate(true)
	var version := clampi(int(data.get("version", 0)), 0, SAVE_VERSION)
	if version == 0:
		data["character_name"] = data.get("character_name", data.get("name", "Wayfarer"))
		data["race_id"] = str(data.get("race_id", data.get("race", "HUMAN"))).to_upper()
		version = 1
	if version == 1:
		data["weapon_slots"] = data.get("weapon_slots", {"1": data.get("equipped_weapon", "training_sword"), "2": ""})
		data["quest_state"] = data.get("quest_state", {})
	var profile := CharacterProfile.new(str(data.get("character_name", "Wayfarer")))
	var loaded_race := StringName(str(data.get("race_id", "HUMAN")).to_upper())
	profile.race_id = loaded_race if RaceData.is_defined(loaded_race) else &"HUMAN"
	profile.level = clampi(int(data.get("level", 1)), 1, MAX_LEVEL)
	profile.exp = maxi(0, int(data.get("exp", 0)))
	profile.gold = maxi(0, int(data.get("gold", 0)))
	profile.max_hp = maxi(1, int(data.get("max_hp", 100 + (profile.level - 1) * 8)))
	profile.hp = clampi(int(data.get("hp", profile.max_hp)), 0, profile.max_hp)
	profile.base_damage = maxi(1, int(data.get("base_damage", 10 + profile.level - 1)))
	profile.inventory = _dictionary_copy(data.get("inventory", profile.inventory))
	profile.equipped_weapon = StringName(str(data.get("equipped_weapon", "training_sword")))
	profile.weapon_slots = _dictionary_copy(data.get("weapon_slots", {"1": String(profile.equipped_weapon), "2": ""}))
	profile.activated_waypoints = _string_array(data.get("activated_waypoints", []))
	profile.completed_quests = _string_array(data.get("completed_quests", []))
	profile.defeated_bosses = _string_array(data.get("defeated_bosses", []))
	profile.opened_chests = _string_array(data.get("opened_chests", []))
	profile.puzzle_state = _dictionary_copy(data.get("puzzle_state", {}))
	profile.current_map = str(data.get("current_map", "village"))
	profile.last_waypoint = str(data.get("last_waypoint", "village_well"))
	profile.quest_state = _dictionary_copy(data.get("quest_state", {}))
	return profile


static func _dictionary_copy(value: Variant) -> Dictionary:
	return value.duplicate(true) if value is Dictionary else {}


static func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for entry in value:
			result.append(str(entry))
	return result
