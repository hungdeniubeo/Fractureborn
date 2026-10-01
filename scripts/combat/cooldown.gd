extends RefCounted
class_name Cooldown

var remaining := 0.0


func start(duration: float) -> void:
	remaining = maxf(0.0, duration)


func tick(delta: float) -> void:
	remaining = maxf(0.0, remaining - maxf(0.0, delta))


func is_ready() -> bool:
	return remaining <= 0.0


func reset() -> void:
	remaining = 0.0
