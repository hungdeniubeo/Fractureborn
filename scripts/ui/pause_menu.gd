extends Control
class_name PauseMenu

@onready var _resume_button: Button = $Frame/Buttons/ResumeButton
@onready var _slots_button: Button = $Frame/Buttons/SlotsButton
@onready var _quit_button: Button = $Frame/Buttons/QuitButton
@onready var _vsync_button: Button = $Frame/Buttons/VSyncButton
@onready var _fullscreen_button: Button = $Frame/Buttons/FullscreenButton


func _ready() -> void:
	_resume_button.pressed.connect(_resume)
	_slots_button.pressed.connect(_return_to_slots)
	_quit_button.pressed.connect(_quit_game)
	_vsync_button.pressed.connect(_toggle_vsync)
	_fullscreen_button.pressed.connect(_toggle_fullscreen)


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
