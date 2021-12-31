extends Control

signal back_pressed

export var text: String

func _ready():
	$HBoxContainer2/Label.text = text

func _on_Back_pressed():
	emit_signal("back_pressed")
