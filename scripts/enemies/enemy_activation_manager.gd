extends Node
class_name EnemyActivationManager

const EnemyController = preload("res://scripts/enemies/enemy_controller.gd")

@export var active_radius := 600.0
@export var boss_active_radius := 300.0
@export var ai_update_interval := 0.2

var player: Node2D
var enemies: Array[EnemyController] = []
var active_enemies: Array[EnemyController] = []
var _activation_timer: Timer
var _ai_timer: Timer


func _ready() -> void:
	_activation_timer = Timer.new()
	_activation_timer.wait_time = 0.4
	_activation_timer.timeout.connect(refresh_activity)
	add_child(_activation_timer)
	_ai_timer = Timer.new()
	_ai_timer.wait_time = ai_update_interval
	_ai_timer.timeout.connect(_update_active_ai)
	add_child(_ai_timer)


func configure(player_node: Node2D) -> void:
	player = player_node
	refresh_activity(true)


func register_enemy(enemy: EnemyController) -> void:
	if enemies.has(enemy):
		return
	var was_empty := enemies.is_empty()
	enemies.append(enemy)
	if was_empty:
		_activation_timer.start()
	enemy.tree_exiting.connect(_on_enemy_exiting.bind(enemy), CONNECT_ONE_SHOT)
	var radius := _activation_radius(enemy)
	var should_activate := player != null and enemy.global_position.distance_squared_to(player.global_position) <= radius * radius
	_set_enemy_active(enemy, should_activate)


func unregister_enemy(enemy: EnemyController) -> void:
	enemies.erase(enemy)
	active_enemies.erase(enemy)
	if enemies.is_empty():
		_activation_timer.stop()
	if active_enemies.is_empty():
		_ai_timer.stop()


func refresh_activity(_force: bool = false) -> void:
	if player == null:
		return
	for index in range(enemies.size() - 1, -1, -1):
		var enemy := enemies[index]
		if not is_instance_valid(enemy):
			enemies.remove_at(index)
			continue
		var radius := _activation_radius(enemy)
		_set_enemy_active(enemy, enemy.global_position.distance_squared_to(player.global_position) <= radius * radius)
	if enemies.is_empty():
		_activation_timer.stop()
		_ai_timer.stop()


func _update_active_ai() -> void:
	if player == null:
		return
	for index in range(active_enemies.size() - 1, -1, -1):
		var enemy := active_enemies[index]
		if not is_instance_valid(enemy) or enemy.is_dead:
			active_enemies.remove_at(index)
			continue
		enemy.update_ai(player, ai_update_interval)
	if active_enemies.is_empty():
		_ai_timer.stop()


func _set_enemy_active(enemy: EnemyController, should_activate: bool) -> void:
	if not is_instance_valid(enemy):
		return
	enemy.set_active(should_activate)
	if should_activate:
		if not active_enemies.has(enemy):
			var was_empty := active_enemies.is_empty()
			active_enemies.append(enemy)
			if was_empty:
				_ai_timer.start()
	else:
		active_enemies.erase(enemy)
		if active_enemies.is_empty():
			_ai_timer.stop()


func _activation_radius(enemy: EnemyController) -> float:
	if enemy.activation_radius_override > 0.0:
		return enemy.activation_radius_override
	return active_radius


func _on_enemy_exiting(enemy: EnemyController) -> void:
	unregister_enemy(enemy)
