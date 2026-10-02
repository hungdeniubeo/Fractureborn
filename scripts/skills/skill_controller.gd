extends Node
class_name SkillController

const Cooldown = preload("res://scripts/combat/cooldown.gd")

signal updated
signal activated(skill_id: StringName)

var actor: Node
var definitions: Array[SkillDefinition] = []
var cooldowns: Dictionary = {}
var active_durations: Dictionary = {}


func configure(owner: Node, skill_definitions: Array[SkillDefinition]) -> void:
	actor = owner
	definitions = skill_definitions.duplicate()
	for definition in definitions:
		cooldowns[definition.skill_id] = Cooldown.new()


func activate(slot_index: int, direction: Vector2) -> bool:
	if slot_index < 0 or slot_index >= definitions.size():
		return false
	var definition := definitions[slot_index]
	var cooldown = cooldowns.get(definition.skill_id)
	if cooldown == null or not cooldown.is_ready():
		return false
	var cooldown_scale := float(actor.call("cooldown_multiplier")) if actor.has_method("cooldown_multiplier") else 1.0
	cooldown.start(definition.cooldown * maxf(0.2, cooldown_scale))
	if definition.activation_type == "strike":
		actor.call("perform_skill_strike", definition, direction)
	else:
		active_durations[definition.skill_id] = definition.duration
		actor.call("apply_skill_buff", definition)
	activated.emit(definition.skill_id)
	updated.emit()
	return true


func advance(delta: float) -> void:
	for skill_id in cooldowns:
		cooldowns[skill_id].tick(delta)
	for skill_id in active_durations.keys():
		active_durations[skill_id] = maxf(0.0, float(active_durations[skill_id]) - delta)
		if float(active_durations[skill_id]) <= 0.0:
			active_durations.erase(skill_id)
			actor.call("clear_skill_buff", skill_id)
			updated.emit()


func cooldown_remaining(slot_index: int) -> float:
	if slot_index < 0 or slot_index >= definitions.size():
		return 0.0
	return cooldowns[definitions[slot_index].skill_id].remaining


func skill_name(slot_index: int) -> String:
	if slot_index < 0 or slot_index >= definitions.size():
		return "—"
	return definitions[slot_index].display_name
