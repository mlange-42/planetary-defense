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
	
	fsm.show_message("bzzzzz...", Consts.MESSAGE_WARNING)
	return false


func _on_Command_text_entered(new_text: String):
	if evaluate(new_text):
		command_edit.text = ""
