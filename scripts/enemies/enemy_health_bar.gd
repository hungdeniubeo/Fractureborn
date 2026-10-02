extends Control
class_name EnemyHealthBar

@onready var bar: ProgressBar = $Bar
@onready var hide_timer: Timer = $HideTimer

var enemy: EnemyController


func _ready() -> void:
	enemy = get_parent() as EnemyController
	if enemy == null:
		return
	hide_timer.timeout.connect(_on_hide_timeout)
	enemy.health_changed.connect(_on_health_changed)
	enemy.died.connect(_on_enemy_died)
	_on_health_changed(enemy.health_current, enemy.health_maximum)


func _on_health_changed(current: int, maximum: int) -> void:
	bar.max_value = maxi(1, maximum)
	bar.value = clampi(current, 0, maximum)
	if current <= 0:
		hide_timer.stop()
		visible = false
	elif current < maximum:
		visible = true
		hide_timer.start()
	else:
		visible = not hide_timer.is_stopped()


func _on_hide_timeout() -> void:
	visible = false


func _on_enemy_died(_enemy: EnemyController) -> void:
	hide_timer.stop()
	visible = false
