extends GuiState
class_name FlowsState

onready var comm_list: ItemList = $Buttons/Commodities


func _ready():
	for comm in Constants.COMM_ALL:
		comm_list.add_item(comm)


func state_exited():
	fsm.planet.clear_flows()


func _on_Back_pressed():
	fsm.pop()


func _on_Commodities_item_selected(index: int):
	var comm: String = Constants.COMM_ALL[index]
	fsm.planet.draw_flows(comm)
