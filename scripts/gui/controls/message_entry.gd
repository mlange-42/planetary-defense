extends HBoxContainer
class_name MessageEntry


var message: MessageManager.Message


func _init(m: MessageManager.Message):
	message = m


func _ready():
	var button = Button.new()
	button.size_flags_vertical = 0
	button.text = "->"
	button.hint_tooltip = "Go to message location"
	button.connect("pressed", self, "_on_button_pressed")
	
	add_child(button)
	
	var message_label = RichTextLabel.new()
	message_label.fit_content_height = true
	message_label.size_flags_horizontal = SIZE_FILL | SIZE_EXPAND
	message_label.bbcode_enabled = true
	message_label.bbcode_text = message.text
	
	var vbox = VBoxContainer.new()
	vbox.alignment = ALIGN_CENTER
	vbox.size_flags_horizontal = SIZE_FILL | SIZE_EXPAND
	add_child(vbox)
	
	vbox.add_child(message_label)


func _on_button_pressed():
	print("Go to location - not implemented")
