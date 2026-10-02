extends RefCounted
class_name LootService


static func roll(table: LootTable, rng: RandomNumberGenerator) -> Dictionary:
	if table == null:
		return {}
	return table.roll_entry(rng)


static func roll_drops(table: LootTable, rng: RandomNumberGenerator) -> Array[Dictionary]:
	var drops: Array[Dictionary] = []
	if table == null:
		return drops
	for entry in table.guaranteed_entries:
		drops.append(entry.duplicate(true))
	var random_drop := roll(table, rng)
	if not random_drop.is_empty():
		drops.append(random_drop)
	return drops


static func gold_amount(minimum: int, maximum: int, rng: RandomNumberGenerator) -> int:
	return rng.randi_range(maxi(0, minimum), maxi(minimum, maximum))
