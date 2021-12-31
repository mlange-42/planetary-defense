extends Control


signal quit_confirmed(save)


func _ready():
	$PanelContainer/VBoxContainer/BackButton.grab_focus()


func _on_BackButton_pressed():
	self.visible = false


func _on_QuitButton_pressed():
	emit_signal("quit_confirmed", false)


func _on_SaveButton_pressed():
	emit_signal("quit_confirmed", true)
