extends Control
class_name PauseMenu


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.025, 0.04, 0.82)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var panel := PanelContainer.new()
	panel.position = Vector2(340, 88)
	panel.size = Vector2(280, 364)
	panel.add_theme_stylebox_override("panel", _panel_style())
	add_child(panel)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 10)
	panel.add_child(layout)
	var title := Label.new()
	title.text = "PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	layout.add_child(title)
	_add_button(layout, "Resume  [Esc]", _resume)
	_add_button(layout, "Save and return to slots", _return_to_slots)
	_add_button(layout, "Save and quit", _quit_game)
	_add_button(layout, "Toggle VSync", _toggle_vsync)
	_add_button(layout, "Toggle fullscreen", _toggle_fullscreen)


func toggle() -> void:
	visible = not visible
	get_tree().paused = visible


func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("pause"):
		_resume()
		get_viewport().set_input_as_handled()


func _resume() -> void:
	visible = false
	get_tree().paused = false


func _return_to_slots() -> void:
	GameSession.save_progress(true)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/save_select.tscn")


func _quit_game() -> void:
	GameSession.save_progress(true)
	get_tree().paused = false
	get_tree().quit()


func _toggle_vsync() -> void:
	var settings = SaveService.performance_settings
	settings.vsync_enabled = not settings.vsync_enabled
	SaveService.save_settings(settings)


func _toggle_fullscreen() -> void:
	var settings = SaveService.performance_settings
	settings.fullscreen = not settings.fullscreen
	SaveService.save_settings(settings)


func _add_button(parent: VBoxContainer, text_value: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(244, 42)
	button.pressed.connect(callback)
	parent.add_child(button)


func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("253443")
	style.border_color = Color("637b88")
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	style.content_margin_top = 14.0
	style.content_margin_bottom = 14.0
	return style
