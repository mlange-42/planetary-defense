extends GuiState
class_name RoadsState

onready var clear_button: Button = $Buttons/Clear

var start_point: int = -1

func _on_Back_pressed():
	fsm.pop()

func state_exited():
	fsm.planet.clear_path()

func on_planet_hovered(node: int):
	if start_point >= 0:
		# warning-ignore:return_value_discarded
		fsm.planet.draw_path(start_point, node)
		
func on_planet_clicked(node: int, button: int):
	if button == BUTTON_LEFT:
		if start_point >= 0:
			if clear_button.pressed:
				fsm.planet.remove_road(start_point, node)
			else:
				fsm.planet.add_road(start_point, node)
			start_point = node
			fsm.planet.clear_path()
		else:
			start_point = node
	else:
		start_point = -1
		fsm.planet.clear_path()
