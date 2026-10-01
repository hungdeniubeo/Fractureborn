extends Node
class_name HealthComponent

signal changed(current: int, maximum: int)
signal depleted

var current := 100
var maximum := 100


func configure(current_value: int, maximum_value: int) -> void:
	maximum = maxi(1, maximum_value)
	current = clampi(current_value, 0, maximum)
	changed.emit(current, maximum)
	if current == 0:
		depleted.emit()


func damage(amount: int) -> int:
	if amount <= 0 or current <= 0:
		return 0
	var applied := mini(current, amount)
	current -= applied
	changed.emit(current, maximum)
	if current == 0:
		depleted.emit()
	return applied


func heal(amount: int) -> int:
	if amount <= 0 or current <= 0:
		return 0
	var before := current
	current = mini(maximum, current + amount)
	var restored := current - before
	if restored > 0:
		changed.emit(current, maximum)
	return restored


func set_maximum(value: int, preserve_ratio: bool = true) -> void:
	var ratio := float(current) / float(maximum) if maximum > 0 else 1.0
	maximum = maxi(1, value)
	current = clampi(int(round(maximum * ratio)) if preserve_ratio else mini(current, maximum), 0, maximum)
	changed.emit(current, maximum)
