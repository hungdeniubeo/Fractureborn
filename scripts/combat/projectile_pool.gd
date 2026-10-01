extends Node
class_name ProjectilePool

const Projectile = preload("res://scripts/combat/projectile.gd")

@export_range(0, 64, 1) var initial_capacity := 12
@export_range(1, 160, 1) var maximum_capacity := 96

var _available: Array[Projectile] = []
var _all: Array[Projectile] = []
var active_count := 0


func _ready() -> void:
	initial_capacity = mini(initial_capacity, maximum_capacity)
	for index in range(initial_capacity):
		_create_projectile()


func fire(origin: Vector2, direction: Vector2, team: String, damage: int, speed: float, travel_limit: float, knockback: float, stagger: float) -> bool:
	var projectile: Projectile
	if _available.is_empty():
		projectile = _create_projectile()
		if projectile != null:
			_available.erase(projectile)
	else:
		projectile = _available.pop_back()
	if projectile == null:
		return false
	active_count += 1
	projectile.launch(origin, direction, team, damage, speed, travel_limit, knockback, stagger)
	return true


func total_count() -> int:
	return _all.size()


func _create_projectile() -> Projectile:
	if _all.size() >= maximum_capacity:
		return null
	var projectile := Projectile.new()
	projectile.name = "Projectile_%d" % _all.size()
	projectile.returned_to_pool.connect(_on_projectile_returned)
	add_child(projectile)
	projectile.visible = false
	_all.append(projectile)
	_available.append(projectile)
	return projectile


func _on_projectile_returned(projectile: Projectile) -> void:
	active_count = maxi(0, active_count - 1)
	if is_instance_valid(projectile) and not _available.has(projectile):
		_available.append(projectile)
