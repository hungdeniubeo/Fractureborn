extends Control
class_name SaveSelect

const CharacterProfile = preload("res://scripts/save/character_profile.gd")
const RaceData = preload("res://scripts/core/race_data.gd")
const RaceCatalog = preload("res://scripts/core/race_catalog.gd")

var _name_input: LineEdit
var _slot_cards: Array[PanelContainer] = []
var _status: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	queue_redraw()
	_build_layout()
	_refresh_slots()


func _draw() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Color("111c28"))
	draw_rect(Rect2(Vector2(0, size.y * 0.68), Vector2(size.x, size.y * 0.32)), Color("172631"))
	for index in range(12):
		var x := float((index * 97 + 41) % maxi(1, int(size.x)))
		var y := float((index * 61 + 27) % maxi(1, int(size.y)))
		draw_rect(Rect2(Vector2(x, y), Vector2(3, 3)), Color(0.60, 0.82, 0.77, 0.26))


func _build_layout() -> void:
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var frame := VBoxContainer.new()
	frame.custom_minimum_size = Vector2(700, 460)
	frame.add_theme_constant_override("separation", 14)
	center.add_child(frame)
	var title := Label.new()
	title.text = "FRACTUREBORN"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 38)
	title.add_theme_color_override("font_color", Color("e2d39d"))
	frame.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "THE GREEN PLAINS ARE CALLING"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 13)
	subtitle.add_theme_color_override("font_color", Color("9bb7c0"))
	frame.add_child(subtitle)
	var create_row := HBoxContainer.new()
	create_row.alignment = BoxContainer.ALIGNMENT_CENTER
	create_row.add_theme_constant_override("separation", 8)
	_name_input = LineEdit.new()
	_name_input.placeholder_text = "Character name"
	_name_input.text = "Wayfarer"
	_name_input.custom_minimum_size = Vector2(260, 40)
	_name_input.max_length = 18
	create_row.add_child(_name_input)
	var race_label := Label.new()
	race_label.text = "Playable race: %s" % RaceCatalog.playable_races()[0].display_name
	race_label.add_theme_color_override("font_color", Color("b9c6c1"))
	create_row.add_child(race_label)
	frame.add_child(create_row)
	var cards := HBoxContainer.new()
	cards.add_theme_constant_override("separation", 12)
	frame.add_child(cards)
	for slot_index in range(1, SaveService.SLOT_COUNT + 1):
		var card := PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.custom_minimum_size = Vector2(210, 238)
		card.add_theme_stylebox_override("panel", _card_style())
		cards.add_child(card)
		_slot_cards.append(card)
	_status = Label.new()
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.add_theme_color_override("font_color", Color("ecc789"))
	_status.custom_minimum_size.y = 24
	frame.add_child(_status)
	var controls := Label.new()
	controls.text = "WASD Move   ·   Mouse Aim   ·   LMB Attack   ·   Space Dodge   ·   Q / E / R Skills   ·   F Interact   ·   Tab Pack"
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.add_theme_font_size_override("font_size", 12)
	controls.add_theme_color_override("font_color", Color("91aab4"))
	frame.add_child(controls)


func _refresh_slots() -> void:
	for slot_index in range(1, SaveService.SLOT_COUNT + 1):
		var card := _slot_cards[slot_index - 1]
		for child in card.get_children():
			child.queue_free()
		var layout := VBoxContainer.new()
		layout.add_theme_constant_override("separation", 10)
		card.add_child(layout)
		var heading := Label.new()
		heading.text = "CHARACTER SLOT  %d" % slot_index
		heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		heading.add_theme_color_override("font_color", Color("9fc4d1"))
		layout.add_child(heading)
		var summary: Dictionary = SaveService.slot_summary(slot_index)
		if summary.occupied:
			var profile = SaveService.load_slot(slot_index)
			if profile == null:
				var broken := Label.new()
				broken.text = "Save could not be read"
				broken.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				layout.add_child(broken)
				var retry := Button.new()
				retry.text = "Unreadable save"
				retry.disabled = true
				layout.add_child(retry)
				continue
			var details := Label.new()
			details.text = "%s\n%s  ·  Level %d\n%s" % [profile.character_name, str(profile.race_id).capitalize(), profile.level, str(profile.current_map).replace("_", " ").capitalize()]
			details.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			layout.add_child(details)
			var continue_button := Button.new()
			continue_button.text = "Continue" if RaceData.is_playable(profile.race_id) else "Unavailable race"
			continue_button.disabled = not RaceData.is_playable(profile.race_id)
			continue_button.pressed.connect(_load_slot.bind(slot_index))
			layout.add_child(continue_button)
		else:
			var empty := Label.new()
			empty.text = "Empty\nHuman · Level 1"
			empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			layout.add_child(empty)
			var create_button := Button.new()
			create_button.text = "Create Human"
			create_button.pressed.connect(_create_slot.bind(slot_index))
			layout.add_child(create_button)


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


func _card_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("253443")
	style.border_color = Color("78949c")
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	style.content_margin_top = 12.0
	style.content_margin_bottom = 12.0
	return style
