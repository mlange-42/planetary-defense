extends GuiState
class_name CitiesState

onready var name_edit = $Buttons/CityName

func _on_Back_pressed():
	fsm.pop()

func on_planet_clicked(node: int, button: int):
	if button == BUTTON_LEFT:
		if not name_edit.text.empty():
			fsm.planet.add_facility("city", node, name_edit.text)
			fsm.pop()
