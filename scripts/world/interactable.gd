@tool
extends Area2D
class_name Interactable

@export var interactable_id: StringName
@export var display_name := "Interact"
@export var kind: StringName:
	set(value):
		kind = value
		queue_redraw()
@export var data: Dictionary = {}
var enabled := true


func configure(id: StringName, label: String, action_kind: StringName, extra_data: Dictionary = {}) -> void:
	interactable_id = id
	display_name = label
	kind = action_kind
	data = extra_data.duplicate(true)
	queue_redraw()


func _ready() -> void:
	collision_layer = 1 << 5
	collision_mask = 1
	monitoring = true
	if get_node_or_null("InteractionShape") == null:
		var shape_node := CollisionShape2D.new()
		shape_node.name = "InteractionShape"
		var shape := CircleShape2D.new()
		shape.radius = 52.0
		shape_node.shape = shape
		add_child(shape_node)


func set_world_active(active: bool) -> void:
	enabled = active
	visible = active
	set_deferred("monitoring", active)


func _draw() -> void:
	var color := Color("e5c77d")
	match kind:
		&"quest_npc":
			color = Color("81c9dc")
		&"waypoint":
			color = Color("a8a3ec")
		&"chest":
			color = Color("e0a453")
		&"rune":
			color = Color("86d4cd")
		&"travel":
			color = Color("d4d88e")
	if bool(data.get("opened", false)):
		color = Color("82858a")
	else:
		draw_circle(Vector2(0, -19), 8.0, color)
	draw_rect(Rect2(-6, -7, 12, 17), color.darkened(0.18))
	draw_rect(Rect2(-9, 3, 18, 4), Color("3d3c47"))
