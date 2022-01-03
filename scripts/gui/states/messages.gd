extends GuiState
class_name MessagesState

onready var container: VBoxContainer = find_node("MessageContainer")

func _ready():
	var msg = fsm.planet.messages
	for m in msg.messages:
		add_message(m)


func add_message(m: MessageManager.Message):
	var entry = MessageEntry.new(m)
	container.add_child(entry)


func _on_Back_pressed():
	fsm.pop()
