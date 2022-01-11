extends GuiState
class_name EditCityState

onready var sliders = {
	Commodities.COMM_ALL[0]: find_node("FoodSlider"),
	Commodities.COMM_ALL[1]: find_node("ResourcesSlider"),
	Commodities.COMM_ALL[2]: find_node("ProductsSlider"),
}
onready var weights = {
	Commodities.COMM_ALL[0]: find_node("FoodWeight"),
	Commodities.COMM_ALL[1]: find_node("ResourcesWeight"),
	Commodities.COMM_ALL[2]: find_node("ProductsWeight"),
}
onready var city_label: Label = find_node("CityLabel")
onready var grow_button: Button = find_node("GrowButton") 
onready var auto_assign: Button = find_node("AutoAssign")


var pointer_offset = -0.03
var indicator: RangeIndicator
var pointer: Spatial
var sub_pointer: GeometryInstance

var city_node: int
var city: City
var button_group: ButtonGroup

var infos = {}

func init(the_fsm: Gui, args: Dictionary):
	.init(the_fsm, args)
	
	indicator = RangeIndicator.new()
	indicator.material_override = Materials.RANGE_CITY_HIGHLIGHT
	fsm.planet.add_child(indicator)
	
	pointer = Spatial.new()
	fsm.planet.add_child(pointer)
	sub_pointer = CSGTorus.new()
	sub_pointer.inner_radius = 0.085
	sub_pointer.outer_radius = 0.115
	sub_pointer.ring_sides = 4
	sub_pointer.sides = 12
	sub_pointer.smooth_faces = true
	pointer.add_child(sub_pointer)
	sub_pointer.translate(Vector3(0, 0, pointer_offset))
	sub_pointer.rotate_x(deg2rad(-90))
	
	
	set_city(args["node"])
	
	var buttons: Container = find_node("LuButtons")
	button_group = ButtonGroup.new()
	for lu in LandUse.LU_NAMES:
		var button := LandUseButton.new()
		button.land_use = lu
		button.group = button_group
		
		var evt = InputEventKey.new()
		evt.pressed = true
		evt.scancode = LandUse.LU_KEYS[lu]
		button.shortcut = ShortCut.new()
		button.shortcut.shortcut = evt
		
		buttons.add_child(button)
	
	var fac_buttons: Container = find_node("FacilityButtons")
	for fac in Facilities.FACILITY_IN_CITY:
		if Facilities.FACILITY_IN_CITY[fac]:
			var button := FacilityButton.new()
			button.facility = fac
			button.group = button_group
			
			var evt = InputEventKey.new()
			evt.pressed = true
			evt.scancode = Facilities.FACILITY_KEYS[fac]
			button.shortcut = ShortCut.new()
			button.shortcut.shortcut = evt
			
			fac_buttons.add_child(button)
	
	# warning-ignore:return_value_discarded
	button_group.connect("pressed", self, "_on_tool_changed")


func set_city(node):
	city_node = node
	city = fsm.planet.roads.get_facility(city_node) as City
	if city_label != null:
		city_label.text = city.name
	update_range()


func state_entered():
	auto_assign.pressed = city.auto_assign_workers
	for i in range(city.commodity_weights.size()):
		sliders[Commodities.COMM_ALL[i]].value = city.commodity_weights[i]
	
	city_label.text = city.name
	fsm.update_facility_info(city.node_id)
	update_city_info()
	update_weights_display()


func state_exited():
	city.auto_assign_workers = auto_assign.pressed
	for i in range(city.commodity_weights.size()):
		city.commodity_weights[i] = sliders[Commodities.COMM_ALL[i]].value


func on_next_turn():
	update_city_info()
	fsm.update_facility_info(city.node_id)


func update_city_info():
	grow_button.hint_tooltip = "Grow city radius.\n Cost: %d\n Maintenance: %d->%d" \
			% [Cities.city_growth_cost(city.radius), Cities.city_maintenance(city.radius), Cities.city_maintenance(city.radius + 1)]


func update_range():
	indicator.draw_range(fsm.planet.planet_data, city.node_id, city.cells, city.radius, Color.white)


func update_weights_display():
	var sum = 0
	var values = []
	for comm in sliders:
		var v = sliders[comm].value
		values.append(v)
		sum += v
	
	for i in range(values.size()):
		var v = round(100 * ((values[i] / sum) if sum > 0 else (1.0 / values.size())))
		weights[Commodities.COMM_ALL[i]].text = "%3d%%" % v


func get_land_use_tool():
	var button = button_group.get_pressed_button()
	if button == null or not button is LandUseButton:
		return null
	else:
		return button.land_use


func get_facility_tool():
	var button = button_group.get_pressed_button()
	if button == null or not button is FacilityButton:
		return null
	else:
		return button.facility


func _on_weights_changed(_value: float):
	update_weights_display()


func _on_tool_changed(_button):
	var curr_tool = get_land_use_tool()
	if curr_tool != null:
		set_pointer(curr_tool, null)
	else:
		curr_tool = get_facility_tool()
		if curr_tool != null:
			set_pointer(null, curr_tool)
		else:
			set_pointer(null, null)


func set_pointer(lu_tool, facility_tool):
	for child in sub_pointer.get_children():
		sub_pointer.remove_child(child)
		child.queue_free()
	
	var child: Spatial = null
	if lu_tool != null:
		child = load(LandUse.LU_SCENES[lu_tool]).instance()
	elif facility_tool != null:
		child = load(Facilities.FACILITY_POINTERS[facility_tool]).instance()
	else:
		return
	
	child.translate(Vector3(0, pointer_offset, 0))
	sub_pointer.add_child(child)
	move_pointer(fsm.get_current_node())


func move_pointer(node: int):
	if node < 0:
		pointer.visible = false
		return
	
	var pos = fsm.planet.planet_data.get_position(node)
	pointer.look_at_from_position(pos, 2 * pos, Vector3.UP)
	
	var curr_tool = get_land_use_tool()
	if curr_tool == null:
		sub_pointer.material_override = preload("res://assets/materials/color/white.tres")
	else:
		if fsm.planet.builder.can_set_land_use(city, node, curr_tool, true)[0]:
			sub_pointer.material_override = preload("res://assets/materials/color/green.tres")
		else:
			sub_pointer.material_override = preload("res://assets/materials/color/red.tres")


func on_planet_entered(_node: int):
	fsm.update_facility_info(city.node_id)
	
func on_planet_exited():
	pointer.visible = false
	fsm.update_facility_info(city.node_id)


func on_planet_hovered(node: int):
	fsm.update_facility_info(city.node_id)
	
	if not node in city.cells:
		#fsm.update_land_use_info(-1)
		pointer.visible = false
		return
	
	#fsm.update_land_use_info(node)
	pointer.visible = true
	move_pointer(node)


func on_planet_clicked(node: int, button: int):
	if button == BUTTON_LEFT:
		var facility: Facility = fsm.planet.get_facility(node)
		if facility != null and facility is City and facility != city:
			state_exited()
			set_city(node)
			state_entered()
			return
	
	if button == BUTTON_RIGHT:
		if button_group.get_pressed_button() == null and city.land_use.has(node):
			var lu = city.land_use[node]
			select_land_use(lu)
		
		var err = fsm.planet.builder.set_land_use(city, node, LandUse.LU_NONE)
		if err != null:
			fsm.show_message(err, Consts.MESSAGE_ERROR)
		else:
			update_city_info()
	
	var curr_tool = get_land_use_tool()
	if curr_tool != null:
		if button == BUTTON_LEFT:
			# warning-ignore:return_value_discarded
			var err = fsm.planet.builder.set_land_use(city, node, curr_tool)
			if err != null:
				fsm.show_message(err, Consts.MESSAGE_ERROR)
		update_city_info()
	else:
		if button == BUTTON_LEFT:
			curr_tool = get_facility_tool()
			if curr_tool != null:
				var fac_err = fsm.planet.add_facility(curr_tool, node, curr_tool, city)
				if fac_err[0] != null:
					fac_err[0].city_node_id = city.node_id
					city.add_facility(node, fac_err[0])
				else:
					fsm.show_message(fac_err[1], Consts.MESSAGE_ERROR)
	
	move_pointer(fsm.get_current_node())


func select_land_use(lu: int):
	for button in button_group.get_buttons():
		if button is LandUseButton and button.land_use == lu:
			button.pressed = true
			return


func _on_GrowButton_pressed():
	var err = fsm.planet.grow_city(city)
	if err == null:
		update_city_info()
		update_range()
	else:
		fsm.show_message(err, Consts.MESSAGE_ERROR)


func _on_BackButton_pressed():
	fsm.pop()


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		fsm.planet.remove_child(indicator)
		fsm.planet.remove_child(pointer)
		indicator.queue_free()
		pointer.queue_free()

