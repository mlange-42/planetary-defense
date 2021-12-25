extends GuiState
class_name RoadsState

var start_point: int = -1

func _on_Back_pressed():
	fsm.pop()

func on_planet_hovered(node: int):
	if start_point >= 0:
		# warning-ignore:return_value_discarded
		fsm.planet.draw_path(start_point, node)
		
func on_planet_clicked(node: int, button: int):
	if button == BUTTON_LEFT:
		if start_point >= 0:
			fsm.planet.add_road(start_point, node)
			start_point = node
			fsm.planet.clear_path()
		else:
			start_point = node
	else:
		start_point = -1
		fsm.planet.clear_path()

