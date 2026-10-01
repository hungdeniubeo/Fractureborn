extends RefCounted
class_name LootService


static func roll(table: LootTable, rng: RandomNumberGenerator) -> Dictionary:
	if table == null:
		return {}
	return table.roll_entry(rng)


static func gold_amount(minimum: int, maximum: int, rng: RandomNumberGenerator) -> int:
	return rng.randi_range(maxi(0, minimum), maxi(minimum, maximum))
