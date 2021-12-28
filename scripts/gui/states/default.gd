extends GuiState
class_name DefaultState


func on_planet_clicked(node: int, button: int):
	if button == BUTTON_LEFT:
		var facility: Facility = fsm.planet.get_facility(node)
		if facility == null:
			return
		
		if facility is City:
			fsm.push("edit_city", {"node": node})

func _on_Road_pressed():
	fsm.push("roads", {})

func _on_Flows_pressed():
	fsm.push("flows", {})

func _on_City_pressed():
	fsm.push("cities", {})

func _on_next_turn():
	fsm.planet.next_turn()

func _on_SaveButton_pressed():
	fsm.planet.save_game()

