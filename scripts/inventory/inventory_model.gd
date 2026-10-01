extends RefCounted
class_name InventoryModel

const CATEGORIES: Array[StringName] = [&"weapons", &"materials", &"consumables"]


static func quantity(inventory: Dictionary, category: StringName, item_id: StringName) -> int:
	var bucket: Variant = inventory.get(String(category), {})
	if not bucket is Dictionary:
		return 0
	return maxi(0, int(bucket.get(String(item_id), 0)))


static func add(inventory: Dictionary, category: StringName, item_id: StringName, amount: int = 1) -> bool:
	if not CATEGORIES.has(category) or item_id == &"" or amount <= 0:
		return false
	var category_key := String(category)
	var item_key := String(item_id)
	var bucket: Variant = inventory.get(category_key, {})
	if not bucket is Dictionary:
		bucket = {}
	if category == &"weapons":
		bucket[item_key] = 1
	else:
		bucket[item_key] = maxi(0, int(bucket.get(item_key, 0))) + amount
	inventory[category_key] = bucket
	return true


static func remove(inventory: Dictionary, category: StringName, item_id: StringName, amount: int = 1) -> bool:
	if amount <= 0 or quantity(inventory, category, item_id) < amount:
		return false
	var category_key := String(category)
	var item_key := String(item_id)
	var bucket: Dictionary = inventory.get(category_key, {})
	var next_quantity := int(bucket.get(item_key, 0)) - amount
	if next_quantity == 0:
		bucket.erase(item_key)
	else:
		bucket[item_key] = next_quantity
	inventory[category_key] = bucket
	return true


static func owns_weapon(inventory: Dictionary, weapon_id: StringName) -> bool:
	return quantity(inventory, &"weapons", weapon_id) > 0
