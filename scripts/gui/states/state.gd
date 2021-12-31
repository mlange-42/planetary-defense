extends Control
class_name GuiState

var fsm: Gui

func init(the_fsm: Gui, _args: Dictionary):
	fsm = the_fsm

func state_entered():
	pass

func state_exited():
	pass

func on_planet_hovered(_node: int):
	pass

func on_planet_clicked(_node: int, _button: int):
	pass

func _unhandled_key_input(event):
	if event.pressed and event.scancode == KEY_ESCAPE:
		fsm.pop()
