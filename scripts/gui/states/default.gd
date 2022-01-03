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

func _on_MainMenuButton_pressed():
	fsm.push("game_menu", {})

func _on_SettingsButton_pressed():
	fsm.push("settings", {})

func _on_MessagesButton_pressed():
	fsm.push("messages", {})

func _on_Road_pressed():
	fsm.push("roads", {})

func _on_Flows_pressed():
	fsm.push("flows", {})

func _on_Build_pressed():
	fsm.push("build", {})

func _on_next_turn():
	fsm.planet.next_turn()
	fsm.push("messages", {})
	fsm.show_message("Next turn", Consts.MESSAGE_INFO)
