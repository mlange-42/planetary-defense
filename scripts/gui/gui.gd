extends Control
class_name Gui

signal next_turn

onready var info_container = $InfoContainer
onready var info_panel = $InfoContainer/Panel/Text

var tool_buttons: ButtonGroup


func _ready():
	tool_buttons = $MarginControls/Controls/BuildButtons/Inspect.group
	tool_buttons.get_buttons()[0].pressed = true


func get_selected_tool():
	var b = tool_buttons.get_pressed_button()
	if b == null:
		return null
	else:
		return b.tool_type


func show_info(text: String):
	info_panel.text = text
	info_container.visible = true


func hide_info():
	info_container.visible = false


func _on_NextTurnButton_pressed():
	emit_signal("next_turn")
