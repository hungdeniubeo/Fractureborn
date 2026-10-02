extends Control
class_name InventoryPanel

const WeaponCatalog = preload("res://scripts/combat/weapon_catalog.gd")
const ITEM_ROW_SCENE = preload("res://scenes/ui/inventory_item_row.tscn")

@onready var _content: VBoxContainer = $Frame/Columns/Pack/Items
@onready var _map_panel: MapPanel = $Frame/Columns/MapColumn/MapPanel

var player: PlayerController
var world: WorldBase
var profile


func configure(owner: PlayerController, game_world: WorldBase) -> void:
	player = owner
	world = game_world
	profile = owner.profile
	if is_node_ready():
		_map_panel.configure(player, world)
		refresh()


func _ready() -> void:
	if player != null:
		_map_panel.configure(player, world)
		refresh()


func set_open(opened: bool) -> void:
	visible = opened
	_map_panel.set_tracking_enabled(opened)


func refresh() -> void:
	if _content == null or profile == null:
		return
	_fill_category($Frame/Columns/Pack/Items/Weapons, &"weapons")
	_fill_category($Frame/Columns/Pack/Items/Materials, &"materials")
	_fill_category($Frame/Columns/Pack/Items/Consumables, &"consumables")


func _fill_category(section: VBoxContainer, category: StringName) -> void:
	var rows: VBoxContainer = section.get_node("Rows")
	for child in rows.get_children():
		rows.remove_child(child)
		child.queue_free()
	var items: Dictionary = profile.inventory.get(String(category), {})
	var ids := items.keys()
	ids.sort()
	section.get_node("Empty").visible = ids.is_empty()
	for item_id in ids:
		var row := ITEM_ROW_SCENE.instantiate() as HBoxContainer
		var count := int(items[item_id])
		var name := str(item_id).replace("_", " ").capitalize()
		var detail := ""
		if category == &"weapons":
			var definition = WeaponCatalog.get_weapon(StringName(str(item_id)))
			if definition != null:
				name = definition.display_name
				detail = definition.description
		var label: Label = row.get_node("ItemName")
		label.text = "  %s%s" % [name, "  ×%d" % count if category != &"weapons" else ""]
		label.tooltip_text = detail if not detail.is_empty() else "%s ×%d" % [name, count]
		var action: Button = row.get_node("ActionButton")
		if category == &"weapons":
			action.text = "Equip"
			action.pressed.connect(player.equip_weapon.bind(StringName(str(item_id))))
		elif category == &"consumables" and item_id == "health_potion":
			action.text = "Use  [H]"
			action.pressed.connect(player.use_health_potion)
		else:
			action.visible = false
		rows.add_child(row)
