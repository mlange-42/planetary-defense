extends GuiState
class_name DefaultState


func on_planet_clicked(node: int, button: int):
	if button == BUTTON_LEFT:
		var facility: Facility = fsm.planet.get_facility(node)
		if facility == null:
			return
		
		fsm.push("edit_city", {"node": node})

func _on_Road_pressed():
	fsm.push("roads", {})

func _on_City_pressed():
	fsm.push("cities", {})
