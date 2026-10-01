extends Node
class_name DodgeComponent

const Cooldown = preload("res://scripts/combat/cooldown.gd")

const BASE_COOLDOWN := 1.2
const DASH_DURATION := 0.14
const INVULNERABILITY_DURATION := 0.22
const DASH_SPEED := 480.0

signal changed

var actor: CharacterBody2D
var cooldown = Cooldown.new()
var dash_remaining := 0.0
var invulnerability_remaining := 0.0
var dash_velocity := Vector2.ZERO


func configure(owner: CharacterBody2D) -> void:
	actor = owner


func request(direction: Vector2) -> bool:
	if actor == null or not cooldown.is_ready() or dash_remaining > 0.0:
		return false
	var dash_direction := direction.normalized()
	if dash_direction.is_zero_approx():
		dash_direction = actor.get("facing_direction")
	if dash_direction.is_zero_approx():
		dash_direction = Vector2.DOWN
	var reduction := float(actor.call("dodge_cooldown_multiplier"))
	cooldown.start(BASE_COOLDOWN * maxf(0.2, reduction))
	dash_velocity = dash_direction * DASH_SPEED
	dash_remaining = DASH_DURATION
	invulnerability_remaining = INVULNERABILITY_DURATION
	changed.emit()
	return true


func advance(delta: float) -> void:
	var was_ready := cooldown.is_ready()
	cooldown.tick(delta)
	dash_remaining = maxf(0.0, dash_remaining - delta)
	invulnerability_remaining = maxf(0.0, invulnerability_remaining - delta)
	if was_ready != cooldown.is_ready():
		changed.emit()


func is_dashing() -> bool:
	return dash_remaining > 0.0


func is_invulnerable() -> bool:
	return invulnerability_remaining > 0.0


func cooldown_remaining() -> float:
	return cooldown.remaining
