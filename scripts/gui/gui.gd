extends Control
class_name Gui

signal next_turn

var tool_buttons: ButtonGroup


func _ready():
	tool_buttons = $Controls/BuildButtons/Factory.group
	tool_buttons.get_buttons()[0].pressed = true


func get_selected_tool():
	var b = tool_buttons.get_pressed_button()
	if b == null:
		return null
	else:
		return b.tool_type


func _on_NextTurnButton_pressed():
	emit_signal("next_turn")
