extends GuiState
class_name FlowsState

onready var comm_list: ItemList = find_node("Commodities")
onready var comm_label: Label = find_node("CommodityLabel")
onready var max_label: Label = find_node("MaxLabel")
onready var gradient_tex: TextureRect = find_node("TextureRect")

onready var min_color_button: ColorPickerButton = find_node("MinColorButton")
onready var max_color_button: ColorPickerButton = find_node("MaxColorButton")

func _ready():
	for comm in Commodities.COMM_ALL:
		comm_list.add_item("", Commodities.COMM_ICONS[comm])
	
	comm_list.add_item("", Commodities.COMM_ICON_ALL)
	
	comm_list.select(0)
	comm_list.grab_focus()
	
	set_colors(Color.white, Color.purple)


func set_colors(low: Color, high: Color):
	var grad: Gradient = gradient_tex.texture.gradient
	grad.colors[0] = low
	grad.colors[-1] = high
	
	min_color_button.color = low
	max_color_button.color = high
	
	if comm_list.is_anything_selected():
		update_flows(comm_list.get_selected_items()[0])
	


func on_planet_clicked(node: int, button: int):
	if button == BUTTON_LEFT:
		var facility: Facility = fsm.planet.get_facility(node)
		if facility != null and facility is City:
			fsm.push("edit_city", {"node": node})
			return


func state_entered():
	if comm_list.is_anything_selected():
		update_flows(comm_list.get_selected_items()[0])


func on_next_turn():
	state_entered()


func state_exited():
	fsm.planet.clear_flows()


func _on_Commodities_item_selected(index: int):
	update_flows(index)


func update_flows(index: int):
	var comm: String = "" if index >= Commodities.COMM_ALL.size() else Commodities.COMM_ALL[index]
	var grad: Gradient = gradient_tex.texture.gradient
	
	var max_value: int = fsm.planet.draw_flows(comm, grad.colors[0], grad.colors[-1])
	max_label.text = str(max_value)
	
	comm_label.text = "All" if comm.empty() else comm


func _on_gradient_color_changed(_color):
	set_colors(min_color_button.color, max_color_button.color)
