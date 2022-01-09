extends Control
class_name GameOptions

signal options_confirmed

onready var fullscreen: CheckButton = find_node("FullscreenButton")

var options: GameSettings

func set_options(opts: GameSettings):
	options = opts
	
	fullscreen.pressed = options.fullscreen


func _on_OkButton_pressed():
	options.fullscreen = fullscreen.pressed
	
	emit_signal("options_confirmed")
