extends GuiState
class_name CheatsState

onready var command_edit: LineEdit = find_node("Command")


func _ready():
	command_edit.grab_focus()


func _on_Back_pressed():
	fsm.pop()


func _on_Cheat_pressed():
	if evaluate(command_edit.text):
		command_edit.text = ""


func evaluate(cmd: String):
	if cmd == "gold":
		fsm.planet.taxes.budget += 1000
		fsm.planet.emit_budget()
		fsm.show_message("Added 1000 to budget", Consts.MESSAGE_INFO)
		return true
	elif cmd.find("attack ") == 0:
		var city_name = cmd.trim_prefix("attack ")
		var node = -1
		var fac = fsm.planet.roads.facilities
		for n in fac:
			var f = fac[n]
			if f is City and f.name == city_name:
				node = n
				break
		
		if node < 0:
			fsm.show_message("No city named %s" % city_name, Consts.MESSAGE_WARNING)
			return false
		
		var event = AirAttack.new()
		event.node_id = node
		fsm.planet.story.add_next_turn_event(event)
		fsm.show_message("%s will be attacked next turn" % city_name, Consts.MESSAGE_INFO)
		return true
	
	fsm.show_message("bzzzzz...", Consts.MESSAGE_WARNING)
	return false


func _on_Command_text_entered(new_text: String):
	if evaluate(new_text):
		command_edit.text = ""
