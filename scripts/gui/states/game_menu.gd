extends GuiState
class_name GameMenuState


func _on_BackButton_pressed():
	fsm.pop()


func _on_SaveButton_pressed():
	fsm.save_game()


func _on_QuitButton_pressed():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
