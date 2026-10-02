extends Control
class_name SaveSelect

const CharacterProfile = preload("res://scripts/save/character_profile.gd")
const RaceData = preload("res://scripts/core/race_data.gd")
const RaceCatalog = preload("res://scripts/core/race_catalog.gd")

@onready var _name_input: LineEdit = $Center/Frame/NameRow/NameInput
@onready var _status: Label = $Center/Frame/Status
@onready var _slot_cards: Array[PanelContainer] = [
	$Center/Frame/SlotCards/Slot1,
	$Center/Frame/SlotCards/Slot2,
	$Center/Frame/SlotCards/Slot3,
]


func _ready() -> void:
	_refresh_slots()


func _refresh_slots() -> void:
	for slot_index in range(1, SaveService.SLOT_COUNT + 1):
		var card := _slot_cards[slot_index - 1]
		var details: Label = card.get_node("Content/Details")
		var action: Button = card.get_node("Content/ActionButton")
		var summary: Dictionary = SaveService.slot_summary(slot_index)
		if summary.occupied:
			var profile = SaveService.load_slot(slot_index)
			if profile == null:
				details.text = "Save could not be read"
				action.text = "Unreadable save"
				action.disabled = true
				continue
			details.text = "%s\n%s · Level %d\n%s" % [
				profile.character_name,
				str(profile.race_id).capitalize(),
				profile.level,
				str(profile.current_map).replace("_", " ").capitalize(),
			]
			action.text = "Continue" if RaceData.is_playable(profile.race_id) else "Unavailable race"
			action.disabled = not RaceData.is_playable(profile.race_id)
			action.pressed.connect(_load_slot.bind(slot_index))
		else:
			details.text = "Empty\nHuman · Level 1"
			action.text = "Create Human"
			action.disabled = false
			action.pressed.connect(_create_slot.bind(slot_index))


func _create_slot(slot_index: int) -> void:
	var profile := CharacterProfile.new(_name_input.text)
	var race_definition = RaceCatalog.playable_races()[0]
	profile.race_id = race_definition.race_id
	profile.max_hp = race_definition.starting_max_hp
	profile.hp = profile.max_hp
	profile.base_damage = race_definition.starting_damage
	if not SaveService.save_now(slot_index, profile):
		_status.text = "Could not save this character. Check available disk space."
		return
	_start_character(slot_index, profile)


func _load_slot(slot_index: int) -> void:
	var profile = SaveService.load_slot(slot_index)
	if profile == null:
		_status.text = "Save could not be read. It was left untouched."
		return
	if not RaceData.is_playable(profile.race_id):
		_status.text = "That race is not playable in this slice. Save left untouched."
		return
	_start_character(slot_index, profile)


func _start_character(slot_index: int, profile) -> void:
	GameSession.begin_character(slot_index, profile)
	var map_id: String = profile.current_map if ["village", "green_plains"].has(profile.current_map) else "village"
	profile.current_map = map_id
	get_tree().change_scene_to_file("res://scenes/world/%s_world.tscn" % map_id)
