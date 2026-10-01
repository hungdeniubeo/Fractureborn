extends RefCounted
class_name DifficultyScaler

const ENEMY_HP_MULTIPLIERS: Array[float] = [1.0, 1.5, 2.0, 2.6]
const ENEMY_DAMAGE_MULTIPLIERS: Array[float] = [1.0, 1.15, 1.30, 1.45]


static func enemy_hp_multiplier(player_count: int) -> float:
	return ENEMY_HP_MULTIPLIERS[clampi(player_count, 1, 4) - 1]


static func enemy_damage_multiplier(player_count: int) -> float:
	return ENEMY_DAMAGE_MULTIPLIERS[clampi(player_count, 1, 4) - 1]
