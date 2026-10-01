extends RefCounted
class_name EnemyCatalog

const RESOURCE_PATHS := {
	&"slime": "res://data/enemies/slime.tres",
	&"goblin": "res://data/enemies/goblin.tres",
	&"goblin_archer": "res://data/enemies/goblin_archer.tres",
	&"goblin_captain": "res://data/enemies/goblin_captain.tres",
	&"ancient_treant": "res://data/enemies/ancient_treant.tres",
}

static var _cache: Dictionary = {}


static func get_definition(enemy_id: StringName) -> EnemyDefinition:
	if _cache.has(enemy_id):
		return _cache[enemy_id]
	var path: String = RESOURCE_PATHS.get(enemy_id, "")
	if path.is_empty():
		return null
	var definition := load(path) as EnemyDefinition
	if definition != null:
		_cache[enemy_id] = definition
	return definition
