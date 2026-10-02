extends CanvasLayer
class_name GameHUD

const Progression = preload("res://scripts/core/progression.gd")
const InventoryModel = preload("res://scripts/inventory/inventory_model.gd")

var player: PlayerController
var world: WorldBase

@onready var _hp_bar: ProgressBar = $Screen/StatusPanel/Stats/HpBar
@onready var _exp_bar: ProgressBar = $Screen/StatusPanel/Stats/ExpBar
@onready var _hp_text: Label = $Screen/StatusPanel/Stats/Top/HpText
@onready var _level_text: Label = $Screen/StatusPanel/Stats/Top/Level
@onready var _exp_text: Label = $Screen/StatusPanel/Stats/ExpText
@onready var _weapon_text: Label = $Screen/WeaponPanel/Content/Weapon
@onready var _gold_text: Label = $Screen/WeaponPanel/Content/Gold
@onready var _potion_button: Button = $Screen/WeaponPanel/Content/PotionButton
@onready var _quest_text: Label = $Screen/QuestPanel/QuestText
@onready var _interaction_text: Label = $Screen/Interaction
@onready var _toast_text: Label = $Screen/Toast
@onready var _cooldown_labels: Array[Label] = [
	$Screen/HotbarPanel/Hotbar/SkillQ,
	$Screen/HotbarPanel/Hotbar/SkillE,
	$Screen/HotbarPanel/Hotbar/SkillR,
	$Screen/HotbarPanel/Hotbar/Dodge,
]
@onready var _cooldown_timer: Timer = $CooldownTimer
@onready var _toast_timer: Timer = $ToastTimer
@onready var _boss_panel: PanelContainer = $Screen/BossPanel
@onready var _boss_text: Label = $Screen/BossPanel/Content/BossName
@onready var _boss_hp: ProgressBar = $Screen/BossPanel/Content/Health
@onready var _boss_stagger: ProgressBar = $Screen/BossPanel/Content/Stagger
@onready var _inventory_panel: InventoryPanel = $Screen/InventoryPanel
@onready var _pause_menu: PauseMenu = $Screen/PauseMenu
@onready var _debug_overlay: DebugOverlay = $Screen/DebugOverlay

var _tracked_boss: BossController
var _inventory_dirty := true
var _last_cooldown_text: Array[String] = ["", "", "", ""]


func configure(owner: PlayerController, game_world: WorldBase) -> void:
	player = owner
	world = game_world


func _ready() -> void:
	_inventory_panel.configure(player, world)
	_debug_overlay.configure(world)
	_potion_button.pressed.connect(player.use_health_potion)
	_cooldown_timer.timeout.connect(_refresh_cooldowns)
	_toast_timer.timeout.connect(func() -> void: _toast_text.visible = false)
	_connect_signals()
	refresh_all()


func refresh_all() -> void:
	refresh_stats()
	refresh_quest()
	refresh_inventory()
	_refresh_cooldowns()


func refresh_stats() -> void:
	if player == null or player.profile == null:
		return
	var health := player.health
	_hp_bar.max_value = health.maximum
	_hp_bar.value = health.current
	_hp_text.text = "HP %d / %d" % [health.current, health.maximum]
	_level_text.text = "LEVEL %d" % player.profile.level
	var exp_target: int = Progression.exp_to_next_level(player.profile.level)
	_exp_bar.max_value = exp_target
	_exp_bar.value = player.profile.exp
	_exp_text.text = "EXP %d / %d" % [player.profile.exp, exp_target]
	_weapon_text.text = player.weapons.current_weapon.display_name if player.weapons.current_weapon != null else "No weapon"
	_gold_text.text = "%d G" % player.profile.gold
	_potion_button.text = "Health Potion ×%d [H]" % InventoryModel.quantity(player.profile.inventory, &"consumables", &"health_potion")
	_update_cooldown_timer_state()


func refresh_quest() -> void:
	if _quest_text != null and GameSession.quest_tracker != null:
		_quest_text.text = "TROUBLE IN GREEN PLAINS\n" + GameSession.quest_tracker.objective()


func refresh_inventory() -> void:
	_inventory_dirty = true
	if _inventory_panel != null and _inventory_panel.visible:
		_inventory_panel.refresh()


func toggle_inventory() -> void:
	_inventory_panel.set_open(not _inventory_panel.visible)
	player.input_locked = _inventory_panel.visible
	if _inventory_panel.visible and _inventory_dirty:
		_inventory_panel.refresh()
		_inventory_dirty = false


func toggle_pause() -> void:
	_pause_menu.toggle()


func toggle_debug_overlay() -> void:
	_debug_overlay.toggle()


func set_interaction_prompt(value: String) -> void:
	_interaction_text.text = value
	_interaction_text.visible = not value.is_empty()


func show_message(message: String) -> void:
	_toast_text.text = message
	_toast_text.visible = true
	_toast_timer.start()


func bind_boss(boss: BossController) -> void:
	if boss == _tracked_boss:
		return
	if is_instance_valid(_tracked_boss):
		if _tracked_boss.health_changed.is_connected(_refresh_boss):
			_tracked_boss.health_changed.disconnect(_refresh_boss)
		if _tracked_boss.phase_changed.is_connected(_refresh_boss_phase):
			_tracked_boss.phase_changed.disconnect(_refresh_boss_phase)
		if _tracked_boss.stagger_changed.is_connected(_refresh_stagger):
			_tracked_boss.stagger_changed.disconnect(_refresh_stagger)
		if _tracked_boss.died.is_connected(_on_boss_died):
			_tracked_boss.died.disconnect(_on_boss_died)
	_tracked_boss = boss
	if not is_instance_valid(boss):
		_boss_panel.visible = false
		return
	_boss_panel.visible = true
	boss.health_changed.connect(_refresh_boss)
	boss.phase_changed.connect(_refresh_boss_phase)
	boss.stagger_changed.connect(_refresh_stagger)
	boss.died.connect(_on_boss_died)
	_refresh_boss(boss.health_current, boss.health_maximum)
	_refresh_boss_phase(boss.phase)
	_refresh_stagger(boss.stagger, boss.stagger_threshold)


func _on_boss_died(_enemy: EnemyController) -> void:
	_boss_panel.visible = false
	_tracked_boss = null


func _connect_signals() -> void:
	player.stats_changed.connect(refresh_stats)
	player.skills.updated.connect(_refresh_cooldowns)
	player.dodge.changed.connect(_refresh_cooldowns)
	player.weapons.weapon_changed.connect(func(_weapon) -> void: refresh_stats())
	GameSession.profile_changed.connect(refresh_stats)
	GameSession.quest_changed.connect(refresh_quest)
	GameSession.inventory_changed.connect(refresh_inventory)


func _refresh_cooldowns() -> void:
	if player == null or _cooldown_labels.is_empty():
		return
	var values := [player.cooldown_remaining(0), player.cooldown_remaining(1), player.cooldown_remaining(2), player.dodge.cooldown_remaining()]
	var titles := ["Q Sword Art", "E Weapon Focus", "R Battle Instinct", "Space Dodge"]
	var any_active := false
	for index in range(values.size()):
		var remaining: float = values[index]
		var value_text := "Ready" if remaining <= 0.0 else "%d s" % ceili(remaining)
		if remaining > 0.0:
			any_active = true
		var full_text := "%s\n%s" % [titles[index], value_text]
		if _last_cooldown_text[index] != full_text:
			_cooldown_labels[index].text = full_text
			_last_cooldown_text[index] = full_text
	if any_active:
		if _cooldown_timer.is_stopped():
			_cooldown_timer.start()
	else:
		_cooldown_timer.stop()


func _update_cooldown_timer_state() -> void:
	if _cooldown_timer != null:
		_refresh_cooldowns()


func _refresh_boss(current: int, maximum: int) -> void:
	if not is_instance_valid(_tracked_boss):
		return
	_boss_text.text = "%s%s" % [_tracked_boss.definition.display_name, " · Phase %d" % _tracked_boss.phase if _tracked_boss.boss_id == &"ancient_treant" else ""]
	_boss_hp.max_value = maximum
	_boss_hp.value = current


func _refresh_boss_phase(phase: int) -> void:
	if not is_instance_valid(_tracked_boss):
		return
	_boss_text.text = "%s · Phase %d" % [_tracked_boss.definition.display_name, phase] if _tracked_boss.boss_id == &"ancient_treant" else _tracked_boss.definition.display_name


func _refresh_stagger(current: float, maximum: float) -> void:
	_boss_stagger.max_value = maximum
	_boss_stagger.value = current
