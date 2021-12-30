extends GuiState
class_name FlowsState

onready var comm_list: ItemList = $Buttons/Commodities
onready var max_label: Label = $Buttons/LegendContainer/VBoxContainer/HBoxContainer/MaxLabel
onready var gradient_tex: TextureRect = $Buttons/LegendContainer/VBoxContainer/AspectRatioContainer/Control/TextureRect

onready var min_color_button: ColorPickerButton = $Buttons/LegendContainer/VBoxContainer/HBoxContainer2/MinColorButton
onready var max_color_button: ColorPickerButton = $Buttons/LegendContainer/VBoxContainer/HBoxContainer/MaxColorButton

onready var prod_container = $Buttons/ProductionPanel/ProductionContainer

var infos = {}

func _ready():
	for comm in Constants.COMM_ALL:
		var info: ProductionInfo = preload("res://scenes/gui/states/flows/production_info.tscn").instance()
		info.set_commodity(comm)
		infos[comm] = info
		prod_container.add_child(info)
		
		comm_list.add_item(comm)
	
	comm_list.add_item("(total)")
	
	comm_list.select(0)
	
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
	
	for comm in Constants.COMM_ALL:
		var info = infos[comm]
		var f = fsm.planet.roads.total_flows.get(comm, 0)
		info.set_values(fsm.planet.roads.total_sources.get(comm, 0), f, fsm.planet.roads.total_sinks.get(comm, 0))


func state_exited():
	fsm.planet.clear_flows()


func _on_Back_pressed():
	fsm.pop()


func _on_Commodities_item_selected(index: int):
	update_flows(index)


func update_flows(index: int):
	var comm: String = "" if index >= Constants.COMM_ALL.size() else Constants.COMM_ALL[index]
	var grad: Gradient = gradient_tex.texture.gradient
	
	var max_value: int = fsm.planet.draw_flows(comm, grad.colors[0], grad.colors[-1])
	max_label.text = str(max_value)


func _on_gradient_color_changed(_color):
	set_colors(min_color_button.color, max_color_button.color)
