extends Resource
class_name LootTable

@export var entries: Array[Dictionary] = []
@export var guaranteed_entries: Array[Dictionary] = []


func roll(rng: RandomNumberGenerator) -> StringName:
	return StringName(str(roll_entry(rng).get("item_id", "")))


func roll_entry(rng: RandomNumberGenerator) -> Dictionary:
	var total_weight := 0.0
	for entry in entries:
		total_weight += maxf(0.0, float(entry.get("weight", 0.0)))
	if total_weight <= 0.0:
		return {}
	var selection := rng.randf_range(0.0, total_weight)
	for entry in entries:
		selection -= maxf(0.0, float(entry.get("weight", 0.0)))
		if selection <= 0.0:
			return entry.duplicate(true)
	return entries.back().duplicate(true)
