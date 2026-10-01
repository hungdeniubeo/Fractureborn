extends Resource
class_name SkillDefinition

@export var skill_id: StringName
@export var display_name := "Skill"
@export_multiline var description := ""
@export var cooldown := 1.0
@export var duration := 0.0
@export_enum("strike", "buff") var activation_type := "strike"
@export var strike_damage_multiplier := 1.0
@export var strike_range := 70.0
@export var strike_stagger := 20.0
@export var effect_weapon_damage := 0.0
@export var effect_attack_speed := 1.0
@export var effect_move_speed := 1.0
@export var effect_dodge_cooldown := 1.0
@export var effect_crit_chance := 0.0
@export var evolution_milestones: Array[int] = [10, 20, 30, 40, 50]
@export var evolution_upgrades: Array[SkillEvolutionDefinition] = []
