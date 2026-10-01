extends CharacterBody2D
class_name PlayerController

signal stats_changed
signal defeated
signal inventory_changed

const HealthComponent = preload("res://scripts/combat/health_component.gd")
const DodgeComponent = preload("res://scripts/combat/dodge_component.gd")
const SkillController = preload("res://scripts/skills/skill_controller.gd")
const WeaponController = preload("res://scripts/combat/weapon_controller.gd")
const SkillDefinition = preload("res://scripts/skills/skill_definition.gd")
const SkillCatalog = preload("res://scripts/skills/skill_catalog.gd")
const InventoryModel = preload("res://scripts/inventory/inventory_model.gd")

const MOVE_SPEED := 170.0
const HEAL_AMOUNT := 45
const SLASH_COLOR := Color("ffe68b")

var profile
var world: Node
var activation_manager: Node
var projectile_pool: Node
var health: HealthComponent
var dodge: DodgeComponent
var skills: SkillController
var weapons: WeaponController
var facing_direction := Vector2.DOWN
var active_weapon_slot := 1
var input_locked := false
var _active_buffs: Dictionary = {}
var _slash_direction := Vector2.DOWN
var _slash_range := 50.0
var _slash_visible := 0.0
var _rng := RandomNumberGenerator.new()


func configure(character_profile, game_world: Node, enemy_manager: Node, pool: Node) -> void:
	profile = character_profile
	world = game_world
	activation_manager = enemy_manager
	projectile_pool = pool


func _ready() -> void:
	add_to_group("players")
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	collision_layer = 1
	collision_mask = (1 << 1) | (1 << 4)
	_rng.randomize()
	var shape_node := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 12.0
	shape_node.shape = shape
	add_child(shape_node)
	health = HealthComponent.new()
	health.name = "Health"
	add_child(health)
	health.changed.connect(_on_health_changed)
	health.depleted.connect(func(): defeated.emit())
	health.configure(profile.hp, profile.max_hp)
	GameSession.profile_changed.connect(_sync_progression_health)
	dodge = DodgeComponent.new()
	dodge.name = "Dodge"
	dodge.configure(self)
	add_child(dodge)
	skills = SkillController.new()
	skills.name = "Skills"
	skills.configure(self, _load_racial_skills())
	add_child(skills)
	weapons = WeaponController.new()
	weapons.name = "Weapons"
	weapons.configure(self, activation_manager, projectile_pool, profile.equipped_weapon)
	add_child(weapons)
	weapons.weapon_changed.connect(_on_weapon_changed)
	queue_redraw()


func _physics_process(delta: float) -> void:
	if profile == null:
		return
	var movement := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	var controller_aim := Vector2(Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left"), Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up"))
	var aim := controller_aim if controller_aim.length_squared() > 0.12 else get_global_mouse_position() - global_position
	if not aim.is_zero_approx():
		facing_direction = aim.normalized()
	dodge.advance(delta)
	skills.advance(delta)
	weapons.advance(delta)
	if input_locked:
		velocity = Vector2.ZERO
		move_and_slide()
		queue_redraw()
		return
	if Input.is_action_just_pressed("dodge"):
		dodge.request(movement if not movement.is_zero_approx() else facing_direction)
	if Input.is_action_just_pressed("skill_1"):
		skills.activate(0, facing_direction)
	if Input.is_action_just_pressed("skill_2"):
		skills.activate(1, facing_direction)
	if Input.is_action_just_pressed("skill_3"):
		skills.activate(2, facing_direction)
	if Input.is_action_just_pressed("weapon_1"):
		equip_slot(1)
	if Input.is_action_just_pressed("weapon_2"):
		equip_slot(2)
	if Input.is_action_just_pressed("quick_heal"):
		use_health_potion()
	if Input.is_action_pressed("attack"):
		weapons.attack(facing_direction, combat_effects())
	if dodge.is_dashing():
		velocity = dodge.dash_velocity
	else:
		velocity = movement * MOVE_SPEED * movement_speed_multiplier()
	move_and_slide()
	_slash_visible = maxf(0.0, _slash_visible - delta)
	queue_redraw()


func take_damage(amount: int, _stagger: float = 0.0, _knockback: Vector2 = Vector2.ZERO) -> void:
	if dodge != null and dodge.is_invulnerable():
		return
	health.damage(amount)
	velocity += _knockback


func base_damage() -> int:
	return int(profile.base_damage)


func perform_skill_strike(definition: SkillDefinition, direction: Vector2) -> void:
	if activation_manager == null:
		return
	var damage := int(round(float(base_damage()) * definition.strike_damage_multiplier))
	for enemy in activation_manager.active_enemies:
		if not is_instance_valid(enemy) or enemy.is_dead:
			continue
		var offset: Vector2 = enemy.global_position - global_position
		if offset.length_squared() <= pow(definition.strike_range, 2) and direction.dot(offset.normalized()) >= 0.15:
			enemy.take_damage(damage, definition.strike_stagger, direction * 110.0)
	spawn_slash(direction, definition.strike_range)


func apply_skill_buff(definition: SkillDefinition) -> void:
	_active_buffs[definition.skill_id] = definition
	stats_changed.emit()


func clear_skill_buff(skill_id: StringName) -> void:
	_active_buffs.erase(skill_id)
	stats_changed.emit()


func combat_effects() -> Dictionary:
	var effects := {"weapon_damage": 0, "attack_speed": 1.0, "crit_chance": 0.0}
	for definition: SkillDefinition in _active_buffs.values():
		effects.weapon_damage += int(definition.effect_weapon_damage)
		effects.attack_speed *= maxf(0.2, definition.effect_attack_speed)
		effects.crit_chance += definition.effect_crit_chance
	return effects


func movement_speed_multiplier() -> float:
	var multiplier := 1.0
	for definition: SkillDefinition in _active_buffs.values():
		multiplier *= definition.effect_move_speed
	return multiplier


func dodge_cooldown_multiplier() -> float:
	var multiplier := 1.0
	for definition: SkillDefinition in _active_buffs.values():
		multiplier *= definition.effect_dodge_cooldown
	return multiplier


func cooldown_multiplier() -> float:
	return 1.0


func use_health_potion() -> bool:
	if health.current >= health.maximum or not InventoryModel.remove(profile.inventory, &"consumables", &"health_potion", 1):
		return false
	health.heal(HEAL_AMOUNT)
	GameSession.inventory_changed.emit()
	GameSession.save_progress()
	inventory_changed.emit()
	return true


func collect_item(category: StringName, item_id: StringName, amount: int = 1) -> bool:
	if not InventoryModel.add(profile.inventory, category, item_id, amount):
		return false
	if category == &"weapons":
		for slot_index in [1, 2]:
			var slot_key := str(slot_index)
			if str(profile.weapon_slots.get(slot_key, "")).is_empty():
				profile.weapon_slots[slot_key] = String(item_id)
				break
	GameSession.inventory_changed.emit()
	GameSession.save_progress()
	inventory_changed.emit()
	return true


func add_gold(amount: int) -> void:
	profile.gold = maxi(0, profile.gold + amount)
	stats_changed.emit()
	GameSession.save_progress()


func equip_slot(slot_index: int) -> void:
	var weapon_id := StringName(str(profile.weapon_slots.get(str(slot_index), "")))
	if weapon_id != &"" and InventoryModel.owns_weapon(profile.inventory, weapon_id) and weapons.equip(weapon_id):
		active_weapon_slot = slot_index
		profile.equipped_weapon = weapon_id
		GameSession.save_progress()


func equip_weapon(weapon_id: StringName) -> bool:
	if not InventoryModel.owns_weapon(profile.inventory, weapon_id) or not weapons.equip(weapon_id):
		return false
	profile.weapon_slots[str(active_weapon_slot)] = String(weapon_id)
	profile.equipped_weapon = weapon_id
	GameSession.save_progress()
	return true


func cooldown_remaining(slot_index: int) -> float:
	return skills.cooldown_remaining(slot_index)


func spawn_slash(direction: Vector2, attack_range: float) -> void:
	_slash_direction = direction
	_slash_range = attack_range
	_slash_visible = 0.14
	queue_redraw()


func _draw() -> void:
	draw_ellipse_placeholder()
	draw_rect(Rect2(-8, -15, 16, 24), Color("62bad0"))
	draw_rect(Rect2(-7, -13, 14, 8), Color("f1c58c"))
	draw_rect(Rect2(-9, -17, 18, 5), Color("344b68"))
	draw_rect(Rect2(-9, 4, 7, 7), Color("334453"))
	draw_rect(Rect2(2, 4, 7, 7), Color("334453"))
	if _active_buffs.has(&"weapon_focus"):
		draw_arc(Vector2.ZERO, 20.0, 0.3, 2.84, 12, Color(0.96, 0.79, 0.44, 0.82), 2.0)
	if _active_buffs.has(&"battle_instinct"):
		draw_arc(Vector2.ZERO, 25.0, -0.9, 0.9, 12, Color(0.55, 0.82, 0.73, 0.68), 2.0)
	var eye_position := facing_direction * 5.0 + Vector2(0, -10)
	draw_rect(Rect2(eye_position - Vector2(1.0, 1.0), Vector2(2.0, 2.0)), Color("253342"))
	if dodge != null and dodge.is_dashing():
		draw_rect(Rect2(-12, -18, 24, 28), Color(0.70, 0.91, 1.0, 0.22))
	if _slash_visible > 0.0:
		var start_angle := _slash_direction.angle() - 0.85
		draw_arc(Vector2.ZERO, _slash_range, start_angle, start_angle + 1.7, 14, SLASH_COLOR, 3.0)


func draw_ellipse_placeholder() -> void:
	draw_circle(Vector2(0, 6), 14.0, Color(0.025, 0.035, 0.045, 0.28))


func _on_health_changed(current: int, maximum: int) -> void:
	profile.hp = current
	profile.max_hp = maximum
	stats_changed.emit()


func _sync_progression_health() -> void:
	if profile == null or health == null or health.maximum == profile.max_hp:
		return
	health.configure(profile.hp, profile.max_hp)


func _on_weapon_changed(weapon: WeaponDefinition) -> void:
	if profile != null and weapon != null:
		profile.equipped_weapon = weapon.weapon_id
		stats_changed.emit()


func _load_racial_skills() -> Array[SkillDefinition]:
	return SkillCatalog.for_race(profile.race_id)
