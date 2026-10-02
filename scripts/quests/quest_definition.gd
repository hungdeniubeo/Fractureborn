extends Resource
class_name QuestDefinition

@export var quest_id: StringName
@export var display_name := "Quest"
@export var required_kills := 5
@export var objective_steps: Array[String] = []
@export var reward_gold := 150
@export var reward_experience := 180
