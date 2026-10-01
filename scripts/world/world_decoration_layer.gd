extends Node2D
class_name WorldDecorationLayer

var trees: Array[Dictionary] = []
var rocks: Array[Dictionary] = []
var signs: Array[Dictionary] = []


func add_tree(position: Vector2, scale: float = 1.0, palette_index: int = 0) -> void:
	trees.append({"position": position, "scale": scale, "palette": palette_index})
	queue_redraw()


func add_rock(position: Vector2, scale: float = 1.0) -> void:
	rocks.append({"position": position, "scale": scale})
	queue_redraw()


func add_sign(position: Vector2, color: Color) -> void:
	signs.append({"position": position, "color": color})
	queue_redraw()


func _draw() -> void:
	for tree in trees:
		var point: Vector2 = tree.position
		var size: float = tree.scale
		var green := [Color("39764a"), Color("4f8a54"), Color("6e9d5b")][int(tree.palette) % 3]
		draw_rect(Rect2(point + Vector2(-5, -2) * size, Vector2(10, 25) * size), Color("75543b"))
		draw_rect(Rect2(point + Vector2(-18, -30) * size, Vector2(36, 35) * size), green.darkened(0.12))
		draw_rect(Rect2(point + Vector2(-14, -34) * size, Vector2(28, 31) * size), green)
		draw_rect(Rect2(point + Vector2(-9, -31) * size, Vector2(7, 5) * size), green.lightened(0.14))
	for rock in rocks:
		var point: Vector2 = rock.position
		var size: float = rock.scale
		draw_rect(Rect2(point + Vector2(-15, -10) * size, Vector2(30, 20) * size), Color("727f7c"))
		draw_rect(Rect2(point + Vector2(-10, -14) * size, Vector2(19, 8) * size), Color("9aa49b"))
	for sign in signs:
		var point: Vector2 = sign.position
		draw_rect(Rect2(point + Vector2(-3, 0), Vector2(6, 22)), Color("74513c"))
		draw_rect(Rect2(point + Vector2(-17, -12), Vector2(34, 16)), sign.color)
