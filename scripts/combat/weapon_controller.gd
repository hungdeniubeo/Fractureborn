extends Node
class_name WeaponController

signal weapon_changed(weapon: WeaponDefinition)
signal fired

const WeaponCatalog = preload("res://scripts/combat/weapon_catalog.gd")

var actor: CharacterBody2D
var activation_manager: Node
var projectile_pool: Node
var current_weapon: WeaponDefinition
var attack_cooldown_remaining := 0.0
var _rng := RandomNumberGenerator.new()


func configure(owner: CharacterBody2D, manager: Node, pool: Node, weapon_id: StringName) -> void:
	actor = owner
	activation_manager = manager
	projectile_pool = pool
	_rng.randomize()
	equip(weapon_id)


func equip(weapon_id: StringName) -> bool:
	var definition := WeaponCatalog.get_weapon(weapon_id)
	if definition == null:
		return false
	current_weapon = definition
	weapon_changed.emit(definition)
	return true


func advance(delta: float) -> void:
	attack_cooldown_remaining = maxf(0.0, attack_cooldown_remaining - delta)


func attack(direction: Vector2, effects: Dictionary = {}) -> bool:
	if current_weapon == null or attack_cooldown_remaining > 0.0:
		return false
	var attack_speed := maxf(0.2, float(effects.get("attack_speed", 1.0)))
	attack_cooldown_remaining = current_weapon.attack_cooldown / attack_speed
	var damage := maxi(1, int(actor.call("base_damage")) + current_weapon.damage_bonus + int(effects.get("weapon_damage", 0)))
	var critical := _rng.randf() < clampf(float(effects.get("crit_chance", 0.0)), 0.0, 0.75)
	if critical:
		damage = int(round(damage * 1.75))
	if current_weapon.weapon_class == "melee":
		_melee_attack(direction, damage, critical)
	else:
		_projectile_attack(direction, damage, critical)
	fired.emit()
	return true


func _melee_attack(direction: Vector2, damage: int, critical: bool) -> void:
	for enemy in activation_manager.active_enemies:
		if not is_instance_valid(enemy) or enemy.is_dead:
			continue
		var offset: Vector2 = enemy.global_position - actor.global_position
		if offset.length_squared() > pow(current_weapon.attack_range, 2):
			continue
		if direction.dot(offset.normalized()) < 0.28:
			continue
		enemy.take_damage(damage, current_weapon.stagger * (1.75 if critical else 1.0), direction * current_weapon.knockback)
	actor.call("spawn_slash", direction, current_weapon.attack_range)


func _projectile_attack(direction: Vector2, damage: int, critical: bool) -> void:
	var count := maxi(1, current_weapon.projectile_count)
	var spread := deg_to_rad(current_weapon.projectile_spread_degrees)
	for index in range(count):
		var step := float(index) / float(maxi(1, count - 1)) - 0.5
		var pellet_direction := direction.rotated(step * spread).normalized()
		projectile_pool.fire(
			actor.global_position + pellet_direction * 18.0,
			pellet_direction,
			"player",
			damage,
			current_weapon.projectile_speed,
			current_weapon.attack_range * 4.0,
			current_weapon.knockback,
			current_weapon.stagger * (1.5 if critical else 1.0)
		)
