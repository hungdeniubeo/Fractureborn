extends EnemyController
class_name BossController

signal phase_changed(phase: int)
signal stagger_changed(current: float, maximum: float)
signal summon_requested(position: Vector2, count: int)
signal boss_defeated(boss_id: StringName)

const STAGGER_THRESHOLD := 100.0
const STUN_DURATION_MS := 2400

var boss_id: StringName = &""
var phase := 1
var stagger := 0.0
var telegraph_kind := ""
var telegraph_center := Vector2.ZERO
var telegraph_direction := Vector2.DOWN
var telegraph_radius := 96.0
var _telegraph_until_ms := 0
var _stunned_until_ms := 0
var _next_boss_attack_ms := 0
var _summons_used := 0
var _captain_combo_remaining := 0
var stagger_threshold := STAGGER_THRESHOLD
var stun_duration_ms := STUN_DURATION_MS


func configure_boss(enemy_definition: EnemyDefinition, id: StringName, target: Node2D, pool: Node, manager: EnemyActivationManager, player_count: int = 1) -> void:
	boss_id = id
	configure(enemy_definition, target, pool, manager, player_count)
	activation_radius_override = manager.boss_active_radius
	stagger_threshold = maxf(1.0, definition.stagger_threshold)
	stun_duration_ms = int(maxf(0.1, definition.stun_duration) * 1000.0)
	_next_boss_attack_ms = Time.get_ticks_msec() + 900


func update_ai(target: Node2D, _delta: float) -> void:
	if not is_active or is_dead or not is_instance_valid(target):
		return
	var now := Time.get_ticks_msec()
	_update_phase()
	if now < _stunned_until_ms:
		movement_direction = Vector2.ZERO
		return
	if stagger >= stagger_threshold:
		stagger = 0.0
		_stunned_until_ms = now + stun_duration_ms
		telegraph_kind = ""
		movement_direction = Vector2.ZERO
		stagger_changed.emit(stagger, stagger_threshold)
		return
	if not telegraph_kind.is_empty():
		if now >= _telegraph_until_ms:
			_resolve_attack(target)
		queue_redraw()
		return
	var offset := target.global_position - global_position
	var distance := offset.length()
	telegraph_direction = offset.normalized() if distance > 0.001 else Vector2.DOWN
	var preferred_distance := 82.0 if boss_id == &"ancient_treant" else 66.0
	movement_direction = telegraph_direction if distance > preferred_distance else Vector2.ZERO
	if now >= _next_boss_attack_ms:
		_begin_attack(target)


func take_damage(amount: int, stagger_amount: float = 0.0, knockback: Vector2 = Vector2.ZERO) -> void:
	if is_dead or amount <= 0:
		return
	var damage_multiplier := 1.25 if Time.get_ticks_msec() < _stunned_until_ms else 1.0
	health_current = maxi(0, health_current - int(round(amount * damage_multiplier)))
	stagger = minf(stagger_threshold, stagger + maxf(0.0, stagger_amount - definition.stagger_resistance))
	knockback_velocity = knockback * 0.35
	state = State.HURT
	_hurt_until_ms = Time.get_ticks_msec() + 100
	health_changed.emit(health_current, health_maximum)
	stagger_changed.emit(stagger, STAGGER_THRESHOLD)
	queue_redraw()
	if health_current == 0:
		boss_defeated.emit(boss_id)
		_die()


func _begin_attack(target: Node2D) -> void:
	var now := Time.get_ticks_msec()
	var distance := global_position.distance_to(target.global_position)
	telegraph_direction = (target.global_position - global_position).normalized()
	telegraph_center = target.global_position
	if boss_id == &"goblin_captain":
		telegraph_kind = "charge" if _captain_combo_remaining == 0 else "combo"
		if _captain_combo_remaining == 0:
			_captain_combo_remaining = 2
		else:
			_captain_combo_remaining -= 1
	else:
		if phase == 1:
			telegraph_kind = "root" if _rng.randf() < 0.55 else "slam"
		elif phase == 2:
			telegraph_kind = "root" if _rng.randf() < 0.68 else "slam"
		else:
			telegraph_kind = "root" if _rng.randf() < 0.6 else "slam"
		if phase >= 2 and _summons_used < 2 and _rng.randf() < 0.4:
			telegraph_kind = "summon"
	telegraph_radius = (112.0 if phase >= 3 else 96.0) if boss_id == &"ancient_treant" else 42.0
	_telegraph_until_ms = now + (650 if boss_id == &"goblin_captain" else 820)
	_next_boss_attack_ms = now + int(_attack_interval() * 1000.0)
	if boss_id == &"goblin_captain" and distance > 200.0:
		telegraph_kind = "charge"
	queue_redraw()


func _resolve_attack(target: Node2D) -> void:
	var kind := telegraph_kind
	telegraph_kind = ""
	if kind == "summon":
		_summons_used += 1
		summon_requested.emit(global_position + Vector2(-42, 20), 2)
		return
	if not is_instance_valid(target):
		return
	var hit := false
	match kind:
		"root":
			hit = target.global_position.distance_to(telegraph_center) <= 52.0
		"slam":
			hit = target.global_position.distance_to(global_position) <= telegraph_radius
		"charge":
			global_position += telegraph_direction * 150.0
			hit = target.global_position.distance_to(global_position) <= 42.0
		"combo":
			hit = (target.global_position - global_position).normalized().dot(telegraph_direction) > 0.6 and target.global_position.distance_to(global_position) <= 72.0
	if hit:
		var damage := int(round(definition.attack_damage * DifficultyScaler.enemy_damage_multiplier(player_count)))
		if phase >= 3:
			damage = int(round(damage * 1.3))
		target.call("take_damage", damage, 0.0, telegraph_direction * 80.0)
	

func _update_phase() -> void:
	if boss_id != &"ancient_treant":
		return
	var ratio := float(health_current) / float(health_maximum)
	var next_phase := 3 if ratio <= definition.phase_three_health_ratio else (2 if ratio <= definition.phase_two_health_ratio else 1)
	if next_phase != phase:
		phase = next_phase
		phase_changed.emit(phase)
		queue_redraw()


func _attack_interval() -> float:
	if boss_id == &"goblin_captain":
		return 1.25 if _captain_combo_remaining > 0 else 2.1
	return 1.55 if phase >= 3 else (1.95 if phase == 2 else 2.35)


func _draw() -> void:
	super._draw()
	if is_dead:
		return
	var size := definition.visual_scale
	draw_rect(Rect2(Vector2(-16, -20) * size, Vector2(32, 5) * size), Color("703b4d"))
	draw_rect(Rect2(Vector2(-11, -19) * size, Vector2(22, 3) * size), Color("f3d695"))
	if boss_id == &"ancient_treant" and phase >= 2:
		draw_rect(Rect2(Vector2(-17, -13) * size, Vector2(34, 4) * size), Color("9abf71"))
	if not telegraph_kind.is_empty():
		var center := to_local(telegraph_center) if telegraph_kind == "root" else Vector2.ZERO
		if telegraph_kind == "charge":
			draw_line(Vector2.ZERO, telegraph_direction * 160.0, Color(1.0, 0.34, 0.25, 0.85), 4.0)
		else:
			draw_arc(center, telegraph_radius, 0.0, TAU, 28, Color(1.0, 0.36, 0.26, 0.8), 3.0)
