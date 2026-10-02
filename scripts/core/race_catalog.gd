extends RefCounted
class_name RaceCatalog

const HUMAN = preload("res://data/races/human.tres")


static func playable_races() -> Array[RaceDefinition]:
	return [HUMAN]


static func get_definition(race_id: StringName) -> RaceDefinition:
	return HUMAN if race_id == &"HUMAN" else null
