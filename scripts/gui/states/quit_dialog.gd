extends GuiState
class_name QuitDialog


func _on_BackButton_pressed():
	fsm.pop()


func _on_QuitButton_pressed():
	get_tree().quit()


func _on_SaveButton_pressed():
	fsm.save_game()
	get_tree().quit()


func get_class(): return "QuitDialog"
