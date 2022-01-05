extends GuiState
class_name DefaultState

onready var messages: MessageWindow = find_node("Messages")
onready var veg_label: Label = find_node("VegetationLabel")


func _ready():
	update_messages(true)


func state_entered():
	update_messages(false)


func on_next_turn():
	update_messages(true)


func _unhandled_key_input(event: InputEventKey):
	if event.pressed:
		if event.scancode == KEY_C and event.control and event.shift:
			fsm.push("cheats", {})
		elif event.scancode == KEY_ESCAPE:
			messages.visible = false


func on_planet_clicked(node: int, button: int):
	if button == BUTTON_LEFT:
		var facility: Facility = fsm.planet.get_facility(node)
		if facility == null:
			return
		
		if facility is City:
			fsm.push("edit_city", {"node": node})

func on_planet_hovered(node: int):
	veg_label.text = fsm.get_node_info(node)

func on_planet_exited():
	veg_label.text = fsm.get_node_info(-1)


func _on_MainMenuButton_pressed():
	fsm.push("game_menu", {})

func _on_SettingsButton_pressed():
	fsm.push("settings", {})

func _on_MessagesButton_pressed():
	messages.visible = not messages.visible

func _on_Road_pressed():
	fsm.push("roads", {})

func _on_Flows_pressed():
	fsm.push("flows", {})

func _on_Build_pressed():
	fsm.push("build", {})

func update_messages(set_visible: bool):
	messages.update_messages(fsm.planet.messages)
	if set_visible and not fsm.planet.messages.messages.empty():
		messages.visible = true

func _on_Messages_go_to_pressed(message):
	var loc = fsm.planet.planet_data.get_position(message.node)
	fsm.go_to(loc)
