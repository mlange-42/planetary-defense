extends Control
class_name GameOptions

signal options_confirmed

onready var fullscreen: CheckButton = find_node("FullscreenButton")

var options: Dictionary

func set_options(opts: Dictionary):
	options = opts
	
	fullscreen.pressed = options.get("fullscreen", false)


func _on_OkButton_pressed():
	options["fullscreen"] = fullscreen.pressed
	
	emit_signal("options_confirmed")
