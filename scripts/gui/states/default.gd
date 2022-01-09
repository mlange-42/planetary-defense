extends GuiState
class_name DefaultState


func _unhandled_key_input(event: InputEventKey):
	if event.pressed:
		if event.scancode == KEY_C and event.control and event.shift:
			fsm.push("cheats", {})


func on_planet_clicked(node: int, button: int):
	if button == BUTTON_LEFT:
		var facility: Facility = fsm.planet.get_facility(node)
		if facility == null:
			return
		
		if facility is City:
			fsm.push("edit_city", {"node": node})
