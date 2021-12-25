extends GuiState
class_name EditCityState

onready var city_text: RichTextLabel = $InfoContainer/VBoxContainer/CityPanel/CityText
onready var node_text: RichTextLabel = $InfoContainer/VBoxContainer/NodePanel/NodeText

var city_node: int
var city: City
var button_group: ButtonGroup


func init(the_fsm: Gui, args: Dictionary):
	.init(the_fsm, args)
	city_node = args["node"]
	city = fsm.planet.roads.get_facility(city_node) as City
	
	button_group = ButtonGroup.new()
	
	for child in $MarginControls/EditCityControls/Buttons.get_children():
		if child is Button and child.toggle_mode:
			child.group = button_group


func _ready():
	update_city_info()


func update_city_info():
	var text = ""
	for comm in Constants.COMM_ALL:
		text += "%-10s +%3d / -%3d\n" % [comm, city.sources.get(comm, 0), city.sinks.get(comm, 0)]
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
