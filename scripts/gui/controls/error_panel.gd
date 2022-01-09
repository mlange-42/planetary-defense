extends Container
class_name ErrorPanel

onready var left_icon: TextureRect = find_node("Icon1")
onready var right_icon: TextureRect = find_node("Icon2")
onready var label: Label = find_node("Label")

func set_message(text: String, level: int):
	label.text = text
	
	var icon = Consts.MESSAGE_ICONS[level]
	left_icon.texture = icon
	right_icon.texture = icon
