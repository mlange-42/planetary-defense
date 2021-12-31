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
			if fsm.planet.add_facility(Constants.FAC_CITY, node, name_edit.text) != null:
				fsm.pop()
