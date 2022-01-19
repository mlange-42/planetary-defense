extends HBoxContainer
class_name MessageEntry

signal go_to_pressed(node)

var message: MessageManager.Message

func _init(m: MessageManager.Message):
	message = m


func _ready():
	var button = TextureButton.new()
	button.size_flags_vertical = SIZE_SHRINK_CENTER
	button.texture_normal = Consts.MESSAGE_ICONS[message.message_type]
	button.hint_tooltip = "Go to message location"
	button.connect("pressed", self, "_on_button_pressed")
	
	add_child(button)
	
	var message_label = RichTextLabel.new()
	message_label.fit_content_height = true
	message_label.size_flags_horizontal = SIZE_FILL | SIZE_EXPAND
	message_label.size_flags_vertical = SIZE_SHRINK_END
	message_label.bbcode_enabled = true
	message_label.bbcode_text = message.text
	
	message_label.connect("meta_clicked", self, "_on_meta_clicked")
	
	var vbox = VBoxContainer.new()
	vbox.alignment = ALIGN_CENTER
	vbox.size_flags_horizontal = SIZE_FILL | SIZE_EXPAND
	add_child(vbox)
	
	vbox.add_child(message_label)
	rect_size = Vector2(0, 0)


func _on_meta_clicked(meta):
	emit_signal("go_to_pressed", int(meta))


func _on_button_pressed():
	emit_signal("go_to_pressed", message.node)
