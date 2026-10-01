extends Resource
class_name EnemyDefinition

@export var enemy_id: StringName
@export var display_name := "Enemy"
@export var max_hp := 30
@export var move_speed := 80.0
@export var attack_damage := 8
@export var attack_cooldown := 1.4
@export var attack_range := 28.0
@export var ranged := false
@export var projectile_speed := 260.0
@export var xp_reward := 12
@export var gold_min := 1
@export var gold_max := 4
@export var stagger_resistance := 0.0
@export var stagger_threshold := 100.0
@export var stun_duration := 2.4
@export_range(0.1, 0.9, 0.01) var phase_two_health_ratio := 0.60
@export_range(0.05, 0.5, 0.01) var phase_three_health_ratio := 0.25
@export var visual_scale := 1.0
@export var body_color := Color("72be7b")
@export var loot_table: LootTable
