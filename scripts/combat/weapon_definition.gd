extends Resource
class_name WeaponDefinition

@export var weapon_id: StringName
@export var display_name := "Weapon"
@export_enum("melee", "projectile") var weapon_class := "melee"
@export var damage_bonus := 0
@export var attack_cooldown := 0.45
@export var attack_range := 52.0
@export var projectile_speed := 420.0
@export var projectile_count := 1
@export_range(0.0, 90.0, 0.1) var projectile_spread_degrees := 0.0
@export var knockback := 60.0
@export var stagger := 8.0
@export_enum("Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic") var rarity := 0
@export_multiline var description := ""
