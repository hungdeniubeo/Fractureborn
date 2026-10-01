extends RefCounted
class_name WeaponCatalog

const RESOURCE_PATHS := {
	&"training_sword": "res://data/weapons/training_sword.tres",
	&"iron_sword": "res://data/weapons/iron_sword.tres",
	&"wooden_bow": "res://data/weapons/wooden_bow.tres",
	&"basic_pistol": "res://data/weapons/basic_pistol.tres",
	&"basic_shotgun": "res://data/weapons/basic_shotgun.tres",
}

static var _cache: Dictionary = {}


static func get_weapon(weapon_id: StringName) -> WeaponDefinition:
	if _cache.has(weapon_id):
		return _cache[weapon_id]
	var path: String = RESOURCE_PATHS.get(weapon_id, "")
	if path.is_empty():
		return null
	var definition = load(path) as WeaponDefinition
	if definition != null:
		_cache[weapon_id] = definition
	return definition


static func all_weapon_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for weapon_id in RESOURCE_PATHS:
		ids.append(weapon_id)
	return ids
