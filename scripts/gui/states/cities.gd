extends GuiState
class_name CitiesState

var names = CityNames.GERMAN

onready var name_edit = $Buttons/HBoxContainer/CityName


func _ready():
	set_random_name()
	name_edit.grab_focus()


func set_random_name():
	name_edit.text = names[randi() % names.size()]


func _on_Back_pressed():
	fsm.pop()


func on_planet_clicked(node: int, button: int):
	if button == BUTTON_LEFT:
		if not name_edit.text.empty():
			var fac_err = fsm.planet.add_facility(Facilities.FAC_CITY, node, name_edit.text)
			if fac_err[0] != null:
				fsm.pop()
			else:
				fsm.show_message(fac_err[1], Consts.MESSAGE_ERROR)
		else:
			fsm.show_message("No city name given!", Consts.MESSAGE_ERROR)
