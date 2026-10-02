extends Area2D
class_name Projectile

signal returned_to_pool(projectile: Projectile)

const PLAYER_PROJECTILE_LAYER := 1 << 2
const ENEMY_PROJECTILE_LAYER := 1 << 3
const PLAYER_LAYER := 1
const ENEMY_LAYER := 1 << 1

var velocity := Vector2.ZERO
var team := "player"
var damage := 1
var knockback := 0.0
var stagger := 0.0
var max_range := 500.0
var max_lifetime := 2.5
var age := 0.0
var traveled := 0.0
var active := false
var _origin := Vector2.ZERO


func _ready() -> void:
	collision_layer = 0
	collision_mask = 0
	monitoring = false
	monitorable = false
	var shape_node := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 4.0
	shape_node.shape = shape
	add_child(shape_node)
	body_entered.connect(_on_body_entered)
	set_physics_process(false)
	queue_redraw()


func launch(start: Vector2, direction: Vector2, projectile_team: String, hit_damage: int, speed: float, travel_limit: float, force: float, stagger_value: float) -> void:
	global_position = start
	_origin = start
	velocity = direction.normalized() * speed
	team = projectile_team
	damage = hit_damage
	knockback = force
	stagger = stagger_value
	max_range = maxf(32.0, travel_limit)
	age = 0.0
	traveled = 0.0
	active = true
	visible = true
	collision_layer = PLAYER_PROJECTILE_LAYER if team == "player" else ENEMY_PROJECTILE_LAYER
	collision_mask = ENEMY_LAYER if team == "player" else PLAYER_LAYER
	set_physics_process(true)
	set_deferred("monitoring", true)
	queue_redraw()


func deactivate() -> void:
	if not active:
		return
	active = false
	visible = false
	velocity = Vector2.ZERO
	set_physics_process(false)
	set_deferred("monitoring", false)
	collision_layer = 0
	collision_mask = 0
	returned_to_pool.emit(self)


func _physics_process(delta: float) -> void:
	var movement := velocity * delta
	global_position += movement
	traveled += movement.length()
	age += delta
	if age >= max_lifetime or traveled >= max_range or global_position.distance_squared_to(_origin) >= pow(max_range, 2):
		deactivate()


func _draw() -> void:
	var color := Color("fff1a6") if team == "player" else Color("ff856e")
	draw_rect(Rect2(-3, -3, 6, 6), color)
	draw_rect(Rect2(-1, -1, 2, 2), Color.WHITE)


func _on_body_entered(body: Node2D) -> void:
	if not active:
		return
	var expected_group := "enemies" if team == "player" else "players"
	if body.is_in_group(expected_group) and body.has_method("take_damage"):
		body.take_damage(damage, stagger, velocity.normalized() * knockback)
	deactivate()
