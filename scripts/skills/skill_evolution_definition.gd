extends Resource
class_name SkillEvolutionDefinition

@export var upgrade_id: StringName
@export var required_level := 10
@export var branching := false
@export var branch_ids: Array[StringName] = []
@export var mechanical_changes: Dictionary = {}
@export var visual_variant := ""
