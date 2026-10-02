extends RefCounted
class_name Progression

const MAX_LEVEL := 50


static func exp_to_next_level(level: int) -> int:
	var safe_level := clampi(level, 1, MAX_LEVEL)
	return 35 + safe_level * 15 + int(pow(safe_level, 1.45) * 4.0)


static func apply_experience(profile, amount: int) -> int:
	if amount <= 0 or int(profile.level) >= MAX_LEVEL:
		return 0
	profile.exp += amount
	var levels_gained := 0
	while int(profile.level) < MAX_LEVEL:
		var threshold := exp_to_next_level(int(profile.level))
		if int(profile.exp) < threshold:
			break
		profile.exp -= threshold
		profile.level += 1
		profile.max_hp += 8
		profile.hp = mini(int(profile.hp) + 8, int(profile.max_hp))
		profile.base_damage += 1
		levels_gained += 1
	if int(profile.level) >= MAX_LEVEL:
		profile.exp = 0
	return levels_gained
