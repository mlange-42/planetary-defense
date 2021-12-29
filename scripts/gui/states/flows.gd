extends GuiState
class_name FlowsState

onready var comm_list: ItemList = $Buttons/Commodities
onready var max_label: Label = $Buttons/PanelContainer/VBoxContainer/MaxLabel
onready var gradient_tex: TextureRect = $Buttons/PanelContainer/VBoxContainer/AspectRatioContainer/Control/TextureRect

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
		update_flows(comm_list.get_selected_items()[0])


func state_exited():
	fsm.planet.clear_flows()


func _on_Back_pressed():
	fsm.pop()


func _on_Commodities_item_selected(index: int):
	update_flows(index)

func update_flows(index: int):
	var comm: String = Constants.COMM_ALL[index]
	var grad: Gradient = gradient_tex.texture.gradient
	
	
	
	var max_value: int = fsm.planet.draw_flows(comm, grad.colors[0], grad.colors[grad.colors.size()-1])
	max_label.text = str(max_value)
