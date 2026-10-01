extends Resource
class_name RaceDefinition

@export var race_id: StringName
@export var display_name := "Race"
@export var playable := false
@export var starting_max_hp := 100
@export var starting_damage := 10
@export var skill_ids: Array[StringName] = []
@export_multiline var gameplay_identity := ""
