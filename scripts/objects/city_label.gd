extends Control
class_name CityLabel

onready var label: Label = $Label

func set_text(text: String):
	label.text = text
	rect_size = Vector2(0, 0)
