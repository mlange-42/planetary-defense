extends GuiState
class_name CitiesState

func _on_Back_pressed():
	fsm.pop()

func on_planet_clicked(node: int, button: int):
	if button == BUTTON_LEFT:
		fsm.planet.add_facility("city", node)
		fsm.pop()
