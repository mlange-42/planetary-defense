extends GuiState
class_name EditCityState

onready var city_text: RichTextLabel = $InfoContainer/VBoxContainer/CityPanel/CityText
onready var node_text: RichTextLabel = $InfoContainer/VBoxContainer/NodePanel/NodeText

onready var sliders = {
	Constants.COMM_ALL[0]: $MarginControls/EditCityControls/PanelContainer/WeightControls/FoodSlider,
	Constants.COMM_ALL[1]: $MarginControls/EditCityControls/PanelContainer/WeightControls/ResourcesSlider,
	Constants.COMM_ALL[2]: $MarginControls/EditCityControls/PanelContainer/WeightControls/ProductsSlider,
}
onready var auto_assign: CheckBox = $MarginControls/EditCityControls/PanelContainer/WeightControls/AutoAssignCheckBox

var city_node: int
var city: City
var button_group: ButtonGroup


func init(the_fsm: Gui, args: Dictionary):
	.init(the_fsm, args)
	city_node = args["node"]
	city = fsm.planet.roads.get_facility(city_node) as City
	
	var buttons: Container = $MarginControls/EditCityControls/Buttons
	button_group = ButtonGroup.new()
	for lu in Constants.LU_NAMES:
		var button = LandUseButton.new()
		button.land_use = lu
		button.text = Constants.LU_NAMES[lu]
		button.group = button_group
		
		buttons.add_child(button)


func _ready():
	update_city_info()


func state_entered():
	auto_assign.pressed = city.auto_assign_workers
	for i in range(city.commodity_weights.size()):
		sliders[Constants.COMM_ALL[i]].value = city.commodity_weights[i]
	
	city.set_label_visible(false)


func state_exited():
	city.auto_assign_workers = auto_assign.pressed
	for i in range(city.commodity_weights.size()):
		city.commodity_weights[i] = sliders[Constants.COMM_ALL[i]].value
	
	city.set_label_visible(true)


func update_city_info():
	var text = "%s\n" % city.name
	for comm in Constants.COMM_ALL:
		var flows = city.flows.get(comm, [0, 0])
		var pot_source = 0
		for key in city.conversions:
			if key[1] == comm:
				var conv = city.conversions[key]
				pot_source += city.sinks.get(key[0], 0) * conv[1] / conv[0]
		text += "%-10s +%d (%d) / -%d (%d)\n" % [comm, flows[0], city.sources.get(comm, 0) + pot_source, flows[1], city.sinks.get(comm, 0)]
	text += "Free workers: %d" % city.workers
	city_text.text = text


func update_node_info(node: int):
	if node < 0:
		node_text.text = ""
		return
		
	var veg = fsm.planet.planet_data.get_node(node).vegetation_type
	
	var text = "%s\n" % Constants.VEG_NAMES[veg]
	for lut in fsm.constants.LU_MAPPING:
		var lu: Constants.LandUse = fsm.constants.LU_MAPPING[lut]
		if veg in lu.vegetations:
			var prod: Constants.VegLandUse = lu.vegetations[veg]
			var prod_string = "" if prod.source == null else (" %2d %s" % [prod.source.amount, prod.source.commodity])
			text += " %-10s%s\n" % [Constants.LU_NAMES[lut], prod_string]
	
	node_text.text = text


func get_tool():
	var button = button_group.get_pressed_button()
	if button == null:
		return null
	else:
		return button.land_use


func _on_Back_pressed():
	fsm.pop()


func on_planet_hovered(node: int):
	if not node in city.cells:
		update_node_info(-1)
		return
	
	update_node_info(node)


func on_planet_clicked(node: int, button: int):	
	var curr_tool = get_tool()
	if curr_tool == null:
		return
	
	if button == BUTTON_LEFT:
		fsm.planet.builder.set_land_use(city, node, curr_tool)
	elif button == BUTTON_RIGHT:
		fsm.planet.builder.set_land_use(city, node, Constants.LU_NONE)
	
	update_city_info()
