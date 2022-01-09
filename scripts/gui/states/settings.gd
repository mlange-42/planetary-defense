extends GuiState
class_name SettingsState

onready var fullscreen: CheckBox = find_node("Fullscreen")
onready var invert_zoom: CheckBox = find_node("InvertZoom")

onready var settings: GameSettings = get_node("/root/Settings")

func _ready():
	fullscreen.pressed = settings.fullscreen
	invert_zoom.pressed = settings.invert_zoom


func state_exited():
	apply_settings()


func apply_settings():
	if settings.fullscreen != fullscreen.pressed:
		OS.window_fullscreen = fullscreen.pressed
	
	settings.fullscreen = fullscreen.pressed
	settings.invert_zoom = invert_zoom.pressed
	
	settings.save(null)


func _on_OkButton_pressed():
	apply_settings()
	fsm.pop()
