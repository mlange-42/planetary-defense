extends GuiState
class_name BuildState

var names = CityNames.GERMAN

onready var name_edit: LineEdit = find_node("CityName")
onready var inspect_button: Button = find_node("Inspect")

var indicator: RangeIndicator

var button_group: ButtonGroup

var cells: Dictionary = {}
var radius: int = 0

var road_start_point: int = -1

func _ready():
	set_random_name()
	
	var build_buttons: Container = find_node("BuildButtons")
	var road_buttons: Container = find_node("RoadButtons")
	
	indicator = RangeIndicator.new()
	indicator.material_override = Materials.RANGE_BUILD
	fsm.planet.add_child(indicator)
	
	button_group = ButtonGroup.new()
	inspect_button.group = button_group
	
	for fac in Facilities.FACILITY_IN_CITY:
		if not Facilities.FACILITY_IN_CITY[fac]:
			var button := FacilityButton.new()
			button.facility = fac
			button.group = button_group
			
			var evt = InputEventKey.new()
			evt.pressed = true
			evt.scancode = Facilities.FACILITY_KEYS[fac]
			button.shortcut = ShortCut.new()
			button.shortcut.shortcut = evt
			
			build_buttons.add_child(button)
	
	
	for road in Roads.ROAD_INFO:
		var button := RoadButton.new()
		button.mode = road
		button.group = button_group
		
		var evt = InputEventKey.new()
		evt.pressed = true
		evt.scancode = Roads.ROAD_KEYS[road]
		button.shortcut = ShortCut.new()
		button.shortcut.shortcut = evt
		
		road_buttons.add_child(button)
	
	# warning-ignore:return_value_discarded
	button_group.connect("pressed", self, "_on_tool_changed")


func _unhandled_key_input(event: InputEventKey):
	if event.pressed:
		if event.scancode == KEY_C and event.control and event.shift:
			fsm.push("cheats", {})


func state_entered():
	indicator.visible = true


func state_exited():
	indicator.visible = false
	fsm.planet.clear_path()


func set_random_name():
	var available = []
	for n in names:
		if fsm.planet.builder.city_name_available(n):
			available.append(n)
	if available.empty():
		name_edit.text = ""
		name_edit.placeholder_text = "Out of names"
	else:
		name_edit.text = available[randi() % available.size()]


func get_facility_tool():
	var button = button_group.get_pressed_button()
	if button == null or not button is FacilityButton:
		return null
	else:
		return button.facility


func get_road_tool():
	var button = button_group.get_pressed_button()
	if button == null or not button is RoadButton:
		return null
	else:
		return button.mode


func on_planet_entered(_node: int):
	var curr_tool = get_facility_tool()
	indicator.visible = curr_tool != null and radius > 0

func on_planet_exited():
	indicator.visible = false
	fsm.planet.clear_path()
	fsm.update_facility_info(fsm.get_current_node())

func on_planet_hovered(node: int):
	var curr_tool = get_facility_tool()
	var road_tool = get_road_tool()
	if curr_tool != null:
		_update_range(node)
		fsm.update_build_info(curr_tool, -1)
	elif road_tool != null:
		if road_start_point >= 0:
			# warning-ignore:return_value_discarded
			var cost = Roads.ROAD_COSTS[road_tool]
			var max_length = 9999 if cost == 0 else fsm.planet.taxes.budget / cost
			var path = fsm.planet.draw_path(road_start_point, node, max_length)
			# warning-ignore:narrowing_conversion
			fsm.update_build_info(road_tool, max(1, path.size() - 1))
		else:
			fsm.update_build_info(road_tool, 1)
	else:
		indicator.visible = false


func on_planet_clicked(node: int, button: int):
	var fac_tool = get_facility_tool()
	var road_tool = get_road_tool()
	
	if button == BUTTON_LEFT and road_tool == null:
		var facility: Facility = fsm.planet.get_facility(node)
		if facility != null and facility is City:
			fsm.push("edit_city", {"node": node})
			return
	
	if fac_tool != null:
		if button == BUTTON_LEFT:
			var is_city = fac_tool == Facilities.FAC_CITY
			if not is_city or not name_edit.text.empty():
				var name = name_edit.text if is_city else fac_tool
				
				if is_city and not fsm.planet.builder.city_name_available(name):
					fsm.show_message("There is already a city named %s!" % name, Consts.MESSAGE_ERROR)
					return
				
				var fac_err = fsm.planet.add_facility(fac_tool, node, name)
				if fac_err[0] != null:
					if is_city:
						set_random_name()
					for button in button_group.get_buttons():
						button.pressed = false
					indicator.visible = false
				else:
					fsm.show_message(fac_err[1], Consts.MESSAGE_ERROR)
			else:
				fsm.show_message("No city name given!", Consts.MESSAGE_ERROR)
		elif button == BUTTON_RIGHT:
			inspect_button.pressed = true
	else:
		if road_tool != null:
			if button == BUTTON_LEFT:
				if road_start_point >= 0:
					if road_tool == Roads.ROAD_CLEAR:
						fsm.planet.remove_road(road_start_point, node)
					else:
						var err = fsm.planet.add_road(road_start_point, node)
						if err != null:
							fsm.show_message(err, Consts.MESSAGE_ERROR)
					
					road_start_point = node
					fsm.planet.clear_path()
				else:
					road_start_point = node
			elif button == BUTTON_RIGHT:
				if road_start_point >= 0:
					road_start_point = -1
					fsm.planet.clear_path()
				else:
					inspect_button.pressed = true


func on_next_turn():
	on_planet_hovered(fsm.get_current_node())


func _on_tool_changed(_button):
	var curr_tool = get_facility_tool()
	var road_tool = get_road_tool()
	if curr_tool != null:
		radius = Facilities.FACILITY_RADIUS[curr_tool]
		fsm.planet.clear_path()
		_update_range(fsm.get_current_node())
		indicator.visible = true
		
		fsm.update_build_info(curr_tool, -1)
	elif road_tool != null:
		radius = 0
		
		indicator.visible = false
		fsm.update_build_info(road_tool, 1)
	else:
		indicator.visible = false
		


func _update_range(node: int):
	if radius == 0 or node < 0:
		indicator.visible = false
		return
	
	cells.clear()
	var temp_cells = fsm.planet.planet_data.get_in_radius(node, radius)
	for c in temp_cells:
		cells[c[0]] = c[1]
	
	var pos = fsm.planet.planet_data.get_position(node)
	indicator.translation = pos
	indicator.look_at(2 * pos, Vector3.UP)
	
	_draw_range(node, radius)


func _draw_range(center: int, new_radius):
	indicator.draw_range(fsm.planet.planet_data, center, cells, new_radius, Color.white)
	indicator.visible = true


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		fsm.planet.remove_child(indicator)
		indicator.queue_free()
