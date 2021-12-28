extends GuiState
class_name FlowsState

onready var comm_list: ItemList = $Buttons/Commodities


func _ready():
	for comm in Constants.COMM_ALL:
		comm_list.add_item(comm)
	
	comm_list.select(0)


func on_planet_clicked(node: int, button: int):
	if button == BUTTON_LEFT:
		var facility: Facility = fsm.planet.get_facility(node)
		if facility != null and facility is City:
			fsm.push("edit_city", {"node": node})
			return


func state_entered():
	if comm_list.is_anything_selected():
		var comm: String = Constants.COMM_ALL[comm_list.get_selected_items()[0]]
		fsm.planet.draw_flows(comm)


func state_exited():
	fsm.planet.clear_flows()


func _on_Back_pressed():
	fsm.pop()


func _on_Commodities_item_selected(index: int):
	var comm: String = Constants.COMM_ALL[index]
	fsm.planet.draw_flows(comm)
