extends Control
class_name MessageWindow

signal go_to_pressed(message)

onready var container: VBoxContainer = find_node("MessageContainer")

func update_messages(messages: MessageManager):
	clear_messages()
	
	for m in messages.messages:
		add_message(m)


func clear_messages():
	for entry in container.get_children():
		entry.disconnect("go_to_pressed", self, "_on_GoTo_pressed")
		container.remove_child(entry)
		entry.queue_free()

func add_message(m: MessageManager.Message):
	var entry = MessageEntry.new(m)
	entry.connect("go_to_pressed", self, "_on_GoTo_pressed")
	container.add_child(entry)


func _on_HideButton_pressed():
	self.visible = false

func _on_GoTo_pressed(message):
	emit_signal("go_to_pressed", message)
