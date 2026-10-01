extends Control
class_name InventoryPanel

const InventoryModel = preload("res://scripts/inventory/inventory_model.gd")
const WeaponCatalog = preload("res://scripts/combat/weapon_catalog.gd")
const MapPanel = preload("res://scripts/ui/map_panel.gd")

var player: PlayerController
var world: WorldBase
var profile
var _content: VBoxContainer
var _map_panel: MapPanel


func configure(owner: PlayerController, game_world: WorldBase) -> void:
	player = owner
	world = game_world
	profile = owner.profile


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	var shade := ColorRect.new()
	shade.color = Color(0.025, 0.04, 0.055, 0.76)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var panel := PanelContainer.new()
	panel.position = Vector2(170, 55)
	panel.size = Vector2(620, 430)
	panel.add_theme_stylebox_override("panel", _panel_style(Color("253443")))
	add_child(panel)
	var layout := HBoxContainer.new()
	layout.add_theme_constant_override("separation", 8)
	panel.add_child(layout)
	var pack := VBoxContainer.new()
	pack.custom_minimum_size.x = 350
	pack.add_theme_constant_override("separation", 8)
	layout.add_child(pack)
	var heading := Label.new()
	heading.text = "PACK  ·  Tab to close"
	heading.add_theme_font_size_override("font_size", 21)
	pack.add_child(heading)
	_content = VBoxContainer.new()
	_content.add_theme_constant_override("separation", 5)
	pack.add_child(_content)
	var map_column := VBoxContainer.new()
	map_column.custom_minimum_size.x = 225
	map_column.add_theme_constant_override("separation", 7)
	layout.add_child(map_column)
	var map_heading := Label.new()
	map_heading.text = "AREA MAP"
	map_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	map_column.add_child(map_heading)
	_map_panel = MapPanel.new()
	_map_panel.configure(player, world)
	_map_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_column.add_child(_map_panel)
	refresh()


func set_open(opened: bool) -> void:
	visible = opened
	if _map_panel != null:
		_map_panel.set_tracking_enabled(opened)


func refresh() -> void:
	if _content == null or profile == null:
		return
	for child in _content.get_children():
		child.queue_free()
	_add_category("WEAPONS", &"weapons")
	_add_category("MATERIALS", &"materials")
	_add_category("CONSUMABLES", &"consumables")


func _add_category(title: String, category: StringName) -> void:
	var label := Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color("9ac3d0"))
	_content.add_child(label)
	var items: Dictionary = profile.inventory.get(String(category), {})
	var ids := items.keys()
	ids.sort()
	if ids.is_empty():
		var empty := Label.new()
		empty.text = "  —"
		_content.add_child(empty)
		return
	for item_id in ids:
		var row := HBoxContainer.new()
		var count := int(items[item_id])
		var name := str(item_id).replace("_", " ").capitalize()
		var detail := ""
		if category == &"weapons":
			var definition = WeaponCatalog.get_weapon(StringName(str(item_id)))
			if definition != null:
				name = definition.display_name
				detail = definition.description
		var item_label := Label.new()
		item_label.text = "  %s%s" % [name, "  ×%d" % count if category != &"weapons" else ""]
		item_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		item_label.tooltip_text = detail if not detail.is_empty() else "%s ×%d" % [name, count]
		row.add_child(item_label)
		if category == &"weapons":
			var equip := Button.new()
			equip.text = "Equip"
			equip.pressed.connect(player.equip_weapon.bind(StringName(str(item_id))))
			row.add_child(equip)
		elif category == &"consumables" and item_id == "health_potion":
			var use := Button.new()
			use.text = "Use  [H]"
			use.pressed.connect(player.use_health_potion)
			row.add_child(use)
		_content.add_child(row)


func _panel_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color("637b88")
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	style.content_margin_left = 14.0
	style.content_margin_right = 14.0
	style.content_margin_top = 11.0
	style.content_margin_bottom = 11.0
	return style
