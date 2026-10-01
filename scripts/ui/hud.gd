extends CanvasLayer
class_name GameHUD

const Progression = preload("res://scripts/core/progression.gd")
const InventoryModel = preload("res://scripts/inventory/inventory_model.gd")
const InventoryPanel = preload("res://scripts/ui/inventory_panel.gd")
const PauseMenu = preload("res://scripts/ui/pause_menu.gd")
const DebugOverlay = preload("res://scripts/ui/debug_overlay.gd")

var player: PlayerController
var world: WorldBase
var _root: Control
var _hp_bar: ProgressBar
var _exp_bar: ProgressBar
var _hp_text: Label
var _level_text: Label
var _exp_text: Label
var _weapon_text: Label
var _gold_text: Label
var _potion_button: Button
var _quest_text: Label
var _interaction_text: Label
var _toast_text: Label
var _cooldown_labels: Array[Label] = []
var _cooldown_timer: Timer
var _toast_timer: Timer
var _boss_panel: PanelContainer
var _boss_text: Label
var _boss_hp: ProgressBar
var _boss_stagger: ProgressBar
var _tracked_boss: BossController
var _inventory_panel: InventoryPanel
var _pause_menu: PauseMenu
var _debug_overlay: DebugOverlay
var _inventory_dirty := true
var _last_cooldown_text: Array[String] = []


func configure(owner: PlayerController, game_world: WorldBase) -> void:
	player = owner
	world = game_world


func _ready() -> void:
	layer = 10
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)
	_build_status_panels()
	_build_quest_panel()
	_build_boss_panel()
	_build_hotbar()
	_build_prompts()
	_build_overlays()
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
	_hp_text.text = "HP  %d / %d" % [health.current, health.maximum]
	_level_text.text = "LEVEL %d" % player.profile.level
	var exp_target: int = Progression.exp_to_next_level(player.profile.level)
	_exp_bar.max_value = exp_target
	_exp_bar.value = player.profile.exp
	_exp_text.text = "EXP  %d / %d" % [player.profile.exp, exp_target]
	_weapon_text.text = player.weapons.current_weapon.display_name if player.weapons.current_weapon != null else "No weapon"
	_gold_text.text = "%d G" % player.profile.gold
	_potion_button.text = "Health Potion  ×%d  [H]" % InventoryModel.quantity(player.profile.inventory, &"consumables", &"health_potion")
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
	_tracked_boss = boss
	if not is_instance_valid(boss):
		_boss_panel.visible = false
		return
	_boss_panel.visible = true
	boss.health_changed.connect(_refresh_boss)
	boss.phase_changed.connect(_refresh_boss_phase)
	boss.stagger_changed.connect(_refresh_stagger)
	_refresh_boss(boss.health_current, boss.health_maximum)
	_refresh_boss_phase(boss.phase)
	_refresh_stagger(boss.stagger, boss.stagger_threshold)


func _build_status_panels() -> void:
	var panel := _panel(_root, Rect2(Vector2(16, 14), Vector2(270, 102)), Color("253443"))
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 2)
	panel.add_child(layout)
	var top := HBoxContainer.new()
	_level_text = _label("LEVEL 1", 15)
	_hp_text = _label("HP 100 / 100", 14)
	_hp_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(_level_text)
	top.add_child(_hp_text)
	layout.add_child(top)
	_hp_bar = _progress_bar(Color("c75b68"))
	layout.add_child(_hp_bar)
	_exp_text = _label("EXP 0 / 54", 11)
	layout.add_child(_exp_text)
	_exp_bar = _progress_bar(Color("69b9cf"))
	_exp_bar.custom_minimum_size.y = 7
	layout.add_child(_exp_bar)


func _build_quest_panel() -> void:
	var panel := _panel(_root, Rect2(Vector2(650, 14), Vector2(294, 75)), Color("253443"))
	_quest_text = _label("TROUBLE IN GREEN PLAINS\nSpeak with Archivist Edda", 13)
	_quest_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(_quest_text)


func _build_boss_panel() -> void:
	_boss_panel = _panel(_root, Rect2(Vector2(328, 16), Vector2(304, 62)), Color("312b35"))
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 2)
	_boss_panel.add_child(layout)
	_boss_text = _label("Boss", 13)
	_boss_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(_boss_text)
	_boss_hp = _progress_bar(Color("c54d57"))
	layout.add_child(_boss_hp)
	_boss_stagger = _progress_bar(Color("d3ba78"))
	_boss_stagger.custom_minimum_size.y = 6
	layout.add_child(_boss_stagger)
	_boss_panel.visible = false


func _build_hotbar() -> void:
	var panel := _panel(_root, Rect2(Vector2(284, 460), Vector2(392, 62)), Color("253443"))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	panel.add_child(row)
	for index in range(4):
		var label := _label("", 12)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(86, 38)
		_cooldown_labels.append(label)
		_last_cooldown_text.append("")
		row.add_child(label)


func _build_prompts() -> void:
	var left := _panel(_root, Rect2(Vector2(16, 448), Vector2(250, 74)), Color("253443"))
	var layout := VBoxContainer.new()
	left.add_child(layout)
	_weapon_text = _label("Training Sword", 14)
	_gold_text = _label("0 G", 12)
	layout.add_child(_weapon_text)
	layout.add_child(_gold_text)
	_potion_button = Button.new()
	_potion_button.custom_minimum_size = Vector2(225, 30)
	_potion_button.pressed.connect(player.use_health_potion)
	layout.add_child(_potion_button)
	_interaction_text = _label("", 14)
	_interaction_text.position = Vector2(345, 423)
	_interaction_text.size = Vector2(270, 28)
	_interaction_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_interaction_text.visible = false
	_root.add_child(_interaction_text)
	_toast_text = _label("", 16)
	_toast_text.position = Vector2(180, 360)
	_toast_text.size = Vector2(600, 52)
	_toast_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_toast_text.visible = false
	_root.add_child(_toast_text)
	var inventory_hint := _label("Tab  Pack    ·    F  Interact    ·    Esc  Pause", 11)
	inventory_hint.position = Vector2(696, 493)
	inventory_hint.size = Vector2(248, 28)
	inventory_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_root.add_child(inventory_hint)


func _build_overlays() -> void:
	_inventory_panel = InventoryPanel.new()
	_inventory_panel.configure(player, world)
	_root.add_child(_inventory_panel)
	_pause_menu = PauseMenu.new()
	_root.add_child(_pause_menu)
	_debug_overlay = DebugOverlay.new()
	_debug_overlay.configure(world)
	_root.add_child(_debug_overlay)
	_cooldown_timer = Timer.new()
	_cooldown_timer.wait_time = 0.1
	_cooldown_timer.timeout.connect(_refresh_cooldowns)
	add_child(_cooldown_timer)
	_toast_timer = Timer.new()
	_toast_timer.one_shot = true
	_toast_timer.wait_time = 2.8
	_toast_timer.timeout.connect(func(): _toast_text.visible = false)
	add_child(_toast_timer)


func _connect_signals() -> void:
	player.stats_changed.connect(refresh_stats)
	player.skills.updated.connect(_refresh_cooldowns)
	player.dodge.changed.connect(_refresh_cooldowns)
	player.weapons.weapon_changed.connect(func(_weapon): refresh_stats())
	GameSession.profile_changed.connect(refresh_stats)
	GameSession.quest_changed.connect(refresh_quest)
	GameSession.inventory_changed.connect(refresh_inventory)


func _refresh_cooldowns() -> void:
	if player == null or _cooldown_labels.is_empty():
		return
	var values := [player.cooldown_remaining(0), player.cooldown_remaining(1), player.cooldown_remaining(2), player.dodge.cooldown_remaining()]
	var titles := ["Q  Sword Art", "E  Weapon Focus", "R  Battle Instinct", "Space  Dodge"]
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
	if any_active and not _cooldown_timer.is_stopped():
		return
	if any_active:
		_cooldown_timer.start()
	else:
		_cooldown_timer.stop()


func _update_cooldown_timer_state() -> void:
	if _cooldown_timer == null:
		return
	_refresh_cooldowns()


func _refresh_boss(current: int, maximum: int) -> void:
	if _tracked_boss == null or not is_instance_valid(_tracked_boss):
		return
	_boss_text.text = "%s%s" % [_tracked_boss.definition.display_name, "  ·  Phase %d" % _tracked_boss.phase if _tracked_boss.boss_id == &"ancient_treant" else ""]
	_boss_hp.max_value = maximum
	_boss_hp.value = current


func _refresh_boss_phase(phase: int) -> void:
	if _tracked_boss == null or not is_instance_valid(_tracked_boss):
		return
	_boss_text.text = "%s  ·  Phase %d" % [_tracked_boss.definition.display_name, phase] if _tracked_boss.boss_id == &"ancient_treant" else _tracked_boss.definition.display_name


func _refresh_stagger(current: float, maximum: float) -> void:
	_boss_stagger.max_value = maximum
	_boss_stagger.value = current


func _panel(parent: Control, rect: Rect2, color: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.position = rect.position
	panel.size = rect.size
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color("647d89")
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	return panel


func _label(value: String, size: int) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", size)
	return label


func _progress_bar(color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.min_value = 0.0
	bar.max_value = 100.0
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 13)
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	fill.set_corner_radius_all(2)
	bar.add_theme_stylebox_override("fill", fill)
	var background := StyleBoxFlat.new()
	background.bg_color = Color("35414b")
	background.set_corner_radius_all(2)
	bar.add_theme_stylebox_override("background", background)
	return bar
