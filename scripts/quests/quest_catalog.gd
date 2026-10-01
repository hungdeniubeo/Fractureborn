extends RefCounted
class_name QuestCatalog

const TROUBLE_IN_GREEN_PLAINS = preload("res://data/quests/trouble_in_green_plains.tres")


static func get_definition(quest_id: StringName) -> QuestDefinition:
	return TROUBLE_IN_GREEN_PLAINS if quest_id == &"trouble_in_green_plains" else null
