extends RefCounted
class_name InputActions


static func install_defaults() -> void:
	_bind_key(&"move_up", KEY_W)
	_bind_key(&"move_down", KEY_S)
	_bind_key(&"move_left", KEY_A)
	_bind_key(&"move_right", KEY_D)
	_bind_key(&"dodge", KEY_SPACE, JOY_BUTTON_X)
	_bind_key(&"skill_1", KEY_Q, JOY_BUTTON_LEFT_SHOULDER)
	_bind_key(&"skill_2", KEY_E, JOY_BUTTON_RIGHT_SHOULDER)
	_bind_key(&"skill_3", KEY_R, JOY_BUTTON_DPAD_UP)
	_bind_key(&"weapon_1", KEY_1, JOY_BUTTON_DPAD_LEFT)
	_bind_key(&"weapon_2", KEY_2, JOY_BUTTON_DPAD_RIGHT)
	_bind_key(&"interact", KEY_F, JOY_BUTTON_Y)
	_bind_key(&"inventory", KEY_TAB, JOY_BUTTON_BACK)
	_bind_key(&"pause", KEY_ESCAPE, JOY_BUTTON_START)
	_bind_key(&"quick_heal", KEY_H, JOY_BUTTON_A)
	_bind_key(&"debug_overlay", KEY_F3)
	_bind_mouse(&"attack", MOUSE_BUTTON_LEFT)
	_bind_axis(&"attack", JOY_AXIS_TRIGGER_RIGHT, 1.0)
	_bind_axis(&"aim_left", JOY_AXIS_RIGHT_X, -1.0)
	_bind_axis(&"aim_right", JOY_AXIS_RIGHT_X, 1.0)
	_bind_axis(&"aim_up", JOY_AXIS_RIGHT_Y, -1.0)
	_bind_axis(&"aim_down", JOY_AXIS_RIGHT_Y, 1.0)
	_bind_axis(&"move_left", JOY_AXIS_LEFT_X, -1.0)
	_bind_axis(&"move_right", JOY_AXIS_LEFT_X, 1.0)
	_bind_axis(&"move_up", JOY_AXIS_LEFT_Y, -1.0)
	_bind_axis(&"move_down", JOY_AXIS_LEFT_Y, 1.0)


static func _prepare(action: StringName) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, 0.2)


static func _bind_key(action: StringName, key: Key, pad_button: JoyButton = JOY_BUTTON_INVALID) -> void:
	_prepare(action)
	var event := InputEventKey.new()
	event.physical_keycode = key
	_add_unique_event(action, event)
	if pad_button != JOY_BUTTON_INVALID:
		var pad_event := InputEventJoypadButton.new()
		pad_event.button_index = pad_button
		_add_unique_event(action, pad_event)


static func _bind_mouse(action: StringName, button: MouseButton) -> void:
	_prepare(action)
	var event := InputEventMouseButton.new()
	event.button_index = button
	_add_unique_event(action, event)


static func _bind_axis(action: StringName, axis: JoyAxis, value: float) -> void:
	_prepare(action)
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = value
	_add_unique_event(action, event)


static func _add_unique_event(action: StringName, event: InputEvent) -> void:
	for existing in InputMap.action_get_events(action):
		if existing.as_text() == event.as_text():
			return
	InputMap.action_add_event(action, event)
