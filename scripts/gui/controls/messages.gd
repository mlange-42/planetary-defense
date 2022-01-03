extends Control
class_name MessageWindow

onready var container: VBoxContainer = find_node("MessageContainer")


func update_messages(messages: MessageManager):
	for n in container.get_children():
		container.remove_child(n)
		n.queue_free()
	
	for m in messages.messages:
		add_message(m)


func add_message(m: MessageManager.Message):
	var entry = MessageEntry.new(m)
	container.add_child(entry)


func _on_HideButton_pressed():
	self.visible = false
