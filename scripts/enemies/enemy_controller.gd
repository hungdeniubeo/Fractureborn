extends CharacterBody2D
class_name EnemyController

signal died(enemy: EnemyController)
signal health_changed(current: int, maximum: int)

const PLAYER_LAYER := 1
const WORLD_LAYER := 1 << 4
const ENEMY_LAYER := 1 << 1

enum State { IDLE, PATROL, CHASE, ATTACK, HURT, DEAD }

var definition: EnemyDefinition
var player: Node2D
var projectile_pool: Node
var activation_manager: EnemyActivationManager
var player_count := 1
var state: State = State.IDLE
var health_current := 1
var health_maximum := 1
var is_dead := false
var is_active := true
var activation_radius_override := 0.0
var movement_direction := Vector2.ZERO
var knockback_velocity := Vector2.ZERO
var _hurt_until_ms := 0
var _next_attack_ms := 0
var _rng := RandomNumberGenerator.new()


func configure(enemy_definition: EnemyDefinition, target: Node2D, pool: Node, manager: EnemyActivationManager, player_count: int = 1) -> void:
	definition = enemy_definition
	player = target
	projectile_pool = pool
	activation_manager = manager
	self.player_count = clampi(player_count, 1, 4)
	health_maximum = maxi(1, int(round(definition.max_hp * DifficultyScaler.enemy_hp_multiplier(self.player_count))))
	health_current = health_maximum


func _ready() -> void:
	add_to_group("enemies")
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	collision_layer = ENEMY_LAYER
	collision_mask = PLAYER_LAYER | WORLD_LAYER
	var shape_node := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape_node == null:
		shape_node = CollisionShape2D.new()
		shape_node.name = "CollisionShape2D"
		add_child(shape_node)
	var shape := CircleShape2D.new()
	shape.radius = 11.0 * definition.visual_scale
	shape_node.shape = shape
	_rng.randomize()
	_next_attack_ms = Time.get_ticks_msec() + 300
	queue_redraw()


func set_active(active: bool) -> void:
	if is_dead or is_active == active:
		return
	is_active = active
	visible = active
	set_physics_process(active)
	collision_layer = ENEMY_LAYER if active else 0
	collision_mask = (PLAYER_LAYER | WORLD_LAYER) if active else 0
	if not active:
		velocity = Vector2.ZERO
		movement_direction = Vector2.ZERO


func update_ai(target: Node2D, _delta: float) -> void:
	if not is_active or is_dead or not is_instance_valid(target):
		return
	if state == State.HURT:
		if Time.get_ticks_msec() < _hurt_until_ms:
			return
		state = State.CHASE
	var offset := target.global_position - global_position
	var distance := offset.length()
	var direction := offset / distance if distance > 0.001 else Vector2.ZERO
	if definition.ranged:
		if distance < definition.attack_range * 0.45:
			movement_direction = -direction
		elif distance > definition.attack_range * 0.88:
			movement_direction = direction
		else:
			movement_direction = Vector2.ZERO
	else:
		movement_direction = direction if distance > definition.attack_range * 0.82 else Vector2.ZERO
	state = State.CHASE if not movement_direction.is_zero_approx() else State.IDLE
	if distance <= definition.attack_range and Time.get_ticks_msec() >= _next_attack_ms:
		_attack_target(target, direction)
		_next_attack_ms = Time.get_ticks_msec() + int(definition.attack_cooldown * 1000.0)


func take_damage(amount: int, _stagger: float = 0.0, knockback: Vector2 = Vector2.ZERO) -> void:
	if is_dead or amount <= 0:
		return
	health_current = maxi(0, health_current - amount)
	knockback_velocity = knockback
	state = State.HURT
	_hurt_until_ms = Time.get_ticks_msec() + 140
	health_changed.emit(health_current, health_maximum)
	queue_redraw()
	if health_current == 0:
		_die()


func _physics_process(delta: float) -> void:
	velocity = movement_direction * definition.move_speed + knockback_velocity
	move_and_slide()
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 360.0 * delta)


func _attack_target(target: Node2D, direction: Vector2) -> void:
	state = State.ATTACK
	if definition.ranged:
		projectile_pool.fire(global_position + direction * 14.0, direction, "enemy", int(round(definition.attack_damage * DifficultyScaler.enemy_damage_multiplier(player_count))), definition.projectile_speed, 640.0, 20.0, 0.0)
	else:
		target.call("take_damage", int(round(definition.attack_damage * DifficultyScaler.enemy_damage_multiplier(player_count))), 0.0, direction * 30.0)


func _die() -> void:
	if is_dead:
		return
	is_dead = true
	state = State.DEAD
	visible = false
	set_physics_process(false)
	collision_layer = 0
	collision_mask = 0
	died.emit(self)
	queue_free()


func _draw() -> void:
	if definition == null:
		return
	var size := definition.visual_scale
	draw_circle(Vector2(0, 5) * size, 13.0 * size, Color(0.03, 0.04, 0.04, 0.25))
	draw_rect(Rect2(Vector2(-12, -11) * size, Vector2(24, 20) * size), definition.body_color)
	draw_rect(Rect2(Vector2(-9, -14) * size, Vector2(18, 6) * size), definition.body_color.lightened(0.18))
	draw_rect(Rect2(Vector2(-7, -7) * size, Vector2(3, 3) * size), Color("222b36"))
	draw_rect(Rect2(Vector2(4, -7) * size, Vector2(3, 3) * size), Color("222b36"))
	if state == State.HURT:
		draw_rect(Rect2(Vector2(-12, -12) * size, Vector2(24, 20) * size), Color(1.0, 0.93, 0.8, 0.2))
