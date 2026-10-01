extends Resource
class_name PerformanceSettings

@export var vsync_enabled := true
@export var fps_limit := 60
@export var fullscreen := false
@export var window_size := Vector2i(1280, 720)
@export_range(0, 2, 1) var particle_quality := 1
@export var screen_shake := true
@export_range(0, 2, 1) var lighting_quality := 0
@export var damage_numbers := true
@export_range(0.0, 1.0, 0.05) var post_processing_intensity := 0.0


func to_dict() -> Dictionary:
	return {
		"vsync_enabled": vsync_enabled,
		"fps_limit": fps_limit,
		"fullscreen": fullscreen,
		"window_size": [window_size.x, window_size.y],
		"particle_quality": particle_quality,
		"screen_shake": screen_shake,
		"lighting_quality": lighting_quality,
		"damage_numbers": damage_numbers,
		"post_processing_intensity": post_processing_intensity,
	}


static func from_dict(data: Dictionary) -> PerformanceSettings:
	var settings := PerformanceSettings.new()
	settings.vsync_enabled = bool(data.get("vsync_enabled", true))
	settings.fps_limit = clampi(int(data.get("fps_limit", 60)), 30, 240)
	settings.fullscreen = bool(data.get("fullscreen", false))
	var resolution: Variant = data.get("window_size", [1280, 720])
	if resolution is Array and resolution.size() >= 2:
		settings.window_size = Vector2i(maxi(640, int(resolution[0])), maxi(360, int(resolution[1])))
	settings.particle_quality = clampi(int(data.get("particle_quality", 1)), 0, 2)
	settings.screen_shake = bool(data.get("screen_shake", true))
	settings.lighting_quality = clampi(int(data.get("lighting_quality", 0)), 0, 2)
	settings.damage_numbers = bool(data.get("damage_numbers", true))
	settings.post_processing_intensity = clampf(float(data.get("post_processing_intensity", 0.0)), 0.0, 1.0)
	return settings


func apply() -> void:
	Engine.max_fps = fps_limit
	if DisplayServer.get_name() == "headless":
		return
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync_enabled else DisplayServer.VSYNC_DISABLED)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	if not fullscreen:
		DisplayServer.window_set_size(window_size)
