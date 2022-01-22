extends GuiState
class_name ChartsState

onready var stats_buttons: StatsButtons = find_node("StatsButtons")

func _ready():
	stats_buttons.set_selected("charts")


func _on_stats_panel_selected(panel):
	fsm.pop()
	fsm.push(panel, {})


func _on_BackButton_pressed():
	fsm.pop()
