extends Area2D
class_name LootPickup

signal collected(category: StringName, item_id: StringName, amount: int)

var category: StringName = &"materials"
var item_id: StringName
var amount := 1
var _claimed := false


func configure(item_category: StringName, item: StringName, quantity: int) -> void:
	category = item_category
	item_id = item
	amount = maxi(1, quantity)


func _ready() -> void:
	add_to_group("loot_pickups")
	collision_layer = 1 << 6
	collision_mask = 1
	monitoring = true
	var shape_node := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 14.0
	shape_node.shape = shape
	add_child(shape_node)
	body_entered.connect(_on_body_entered)
	queue_redraw()


func _draw() -> void:
	var color := Color("80d98e")
	if category == &"gold":
		color = Color("f3d16f")
	elif category == &"weapons":
		color = Color("d5e0eb")
	elif category == &"consumables":
		color = Color("e78c8c")
	draw_rect(Rect2(-6, -6, 12, 12), color.darkened(0.15))
	draw_rect(Rect2(-3, -8, 6, 4), color.lightened(0.2))


func _on_body_entered(body: Node2D) -> void:
	if _claimed or not body.has_method("collect_item"):
		return
	var accepted := false
	if category == &"gold":
		body.call("add_gold", amount)
		accepted = true
	else:
		accepted = body.call("collect_item", category, item_id, amount)
	if accepted:
		_claimed = true
		collected.emit(category, item_id, amount)
		queue_free()
