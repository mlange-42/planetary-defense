extends GuiState
class_name EditCityState

var city_node: int
var button_group: ButtonGroup

func init(the_fsm: Gui, args: Dictionary):
	.init(the_fsm, args)
	city_node = args["node"]
	
	button_group = ButtonGroup.new()
	
	for child in $Buttons.get_children():
		if child is Button and child.toggle_mode:
			child.group = button_group

func get_tool():
	var button = button_group.get_pressed_button()
	if button == null:
		return null
	else:
		return button.land_use

func _on_Back_pressed():
	fsm.pop()

func on_planet_clicked(node: int, button: int):	
	var curr_tool = get_tool()
	if curr_tool == null:
		return
	
	var facility = fsm.planet.roads.get_facility(city_node)
	
	if not facility is City:
		return
	
	var city: City = facility as City
	
	if button == BUTTON_LEFT:
		fsm.planet.builder.set_land_use(city, node, curr_tool)
	elif button == BUTTON_RIGHT:
		fsm.planet.builder.set_land_use(city, node, Constants.LU_NONE)
