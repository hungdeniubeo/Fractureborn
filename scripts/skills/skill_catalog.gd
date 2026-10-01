extends RefCounted
class_name SkillCatalog

const SKILL_RESOURCE_PATHS := {
	&"sword_art": "res://data/skills/sword_art.tres",
	&"weapon_focus": "res://data/skills/weapon_focus.tres",
	&"battle_instinct": "res://data/skills/battle_instinct.tres",
}

const RaceCatalog = preload("res://scripts/core/race_catalog.gd")
static var _cache: Dictionary = {}


static func for_race(race_id: StringName) -> Array[SkillDefinition]:
	if _cache.has(race_id):
		return _cache[race_id].duplicate()
	var race = RaceCatalog.get_definition(race_id)
	var definitions: Array[SkillDefinition] = []
	if race == null:
		return definitions
	for skill_id in race.skill_ids:
		var path: String = SKILL_RESOURCE_PATHS.get(skill_id, "")
		if path.is_empty():
			continue
		var definition := load(path) as SkillDefinition
		if definition != null:
			definitions.append(definition)
	_cache[race_id] = definitions
	return definitions.duplicate()
