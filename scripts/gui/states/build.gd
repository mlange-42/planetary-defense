extends GuiState
class_name BuildState

onready var inspect_button: Button = find_node("Inspect")
onready var remove_button: Button = find_node("Remove")

var clear_button: Button

var indicator: RangeIndicator
var cov_indicator: CoverageIndicator

var pointer_offset = -0.03
var pointer: Spatial
var sub_pointer: GeometryInstance

var button_group: ButtonGroup

var facility_functions: Facilities.FacilityFunctions = Facilities.FacilityFunctions.new()

var cells: Dictionary = {}
var radius: int = 0
var coverage: int = 0

var road_start_point: int = -1

func _ready():
	var build_buttons: Container = find_node("BuildButtons")
	var road_buttons: Container = find_node("RoadButtons")
	
	indicator = RangeIndicator.new()
	indicator.material_override = Materials.RANGE_BUILD
	fsm.planet.add_child(indicator)
	
	cov_indicator = CoverageIndicator.new(48, fsm.planet.sky_geometry.radius)
	cov_indicator.material_override = Materials.VERTEX_COLOR
	cov_indicator.visible = false
	fsm.planet.add_child(cov_indicator)
	
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
	
	
	button_group = ButtonGroup.new()
	inspect_button.group = button_group
	remove_button.group = button_group
	
	for fac in Facilities.FACILITY_ICONS:
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
	
	
	for road in Network.TYPE_INFO:
		var button := RoadButton.new()
		button.mode = road
		
		if road == Network.T_CLEAR:
			clear_button = button
		else:
			button.group = button_group
		
		var evt = InputEventKey.new()
		evt.pressed = true
		evt.scancode = Network.TYPE_KEYS[road]
		button.shortcut = ShortCut.new()
		button.shortcut.shortcut = evt
		
		road_buttons.add_child(button)
	
	# warning-ignore:return_value_discarded
	button_group.connect("pressed", self, "_on_tool_changed")
	# warning-ignore:return_value_discarded
	clear_button.connect("pressed", self, "_on_ClearButton_pressed")


func _unhandled_key_input(event: InputEventKey):
	if event.pressed:
		if event.scancode == KEY_C and event.control and event.shift:
			fsm.push("cheats", {})


func state_entered():
	road_start_point = -1
	var curr_tool = get_facility_tool()
	if curr_tool != null:
		_update_range(fsm.get_current_node())
	
	pointer.visible = true
	move_pointer(fsm.get_current_node())


func state_exited():
	indicator.visible = false
	cov_indicator.visible = false
	pointer.visible = false
	fsm.planet.clear_path()


func get_facility_tool():
	var button = button_group.get_pressed_button()
	if button == null or not button is FacilityButton:
		return null
	else:
		return button.facility


func get_road_tool():
	var button = button_group.get_pressed_button()
	if button == null or not button is RoadButton or button.mode == Network.T_CLEAR:
		return null
	else:
		return button.mode


func set_pointer(facility_tool, road_tool):
	for child in sub_pointer.get_children():
		sub_pointer.remove_child(child)
		child.queue_free()
	
	var child: Spatial = null
	if facility_tool != null:
		child = load(Facilities.FACILITY_POINTERS[facility_tool]).instance()
	elif road_tool != null:
		return # TODO
	else:
		return
	
	child.translate(Vector3(0, pointer_offset, 0))
	child.scale = Vector3(0.8, 0.8, 0.8)
	sub_pointer.add_child(child)
	move_pointer(fsm.get_current_node())


func move_pointer(node: int):
	if node < 0:
		pointer.visible = false
		return
	
	var pos = fsm.planet.planet_data.get_position(node)
	pointer.look_at_from_position(pos, 2 * pos, Vector3.UP)
	
	var curr_tool = get_facility_tool()
	if curr_tool == null:
		sub_pointer.material_override = preload("res://assets/materials/color/white.tres")
	else:
		if facility_functions.can_build(curr_tool, fsm.planet, node, null):
			sub_pointer.material_override = preload("res://assets/materials/color/green.tres")
		else:
			sub_pointer.material_override = preload("res://assets/materials/color/red.tres")


func on_planet_entered(_node: int):
	var curr_tool = get_facility_tool()
	indicator.visible = curr_tool != null and radius > 0
	cov_indicator.visible = curr_tool != null and coverage > 0

func on_planet_exited():
	indicator.visible = false
	cov_indicator.visible = false
	pointer.visible = false
	fsm.planet.clear_path()
	fsm.update_facility_info(fsm.get_current_node())

func on_planet_hovered(node: int):
	if node < 0:
		return
	
	var curr_tool = get_facility_tool()
	var road_tool = get_road_tool()
	if curr_tool != null:
		if node < 0:
			radius = 0
			coverage = 0
		else:
			radius = facility_functions.calc_range(curr_tool, fsm.planet.planet_data, node)
			coverage = facility_functions.calc_coverage(curr_tool, fsm.planet.planet_data, node)
		
		_update_range(node)
		fsm.update_build_info(curr_tool, -1)
	elif road_tool != null:
		if road_start_point >= 0:
			# warning-ignore:return_value_discarded
			var cost = Network.TYPE_COSTS[road_tool]
			var clear = clear_button.pressed
			var max_length = 9999 if cost == 0 or clear else fsm.planet.taxes.budget / cost
			var path = fsm.planet.draw_path(road_start_point, node, road_tool, clear, max_length)
			# warning-ignore:narrowing_conversion
			fsm.update_build_info(road_tool, max(1, path.size() - 1))
		else:
			fsm.update_build_info(road_tool, 1)
	else:
		indicator.visible = false
		cov_indicator.visible = false
	
	pointer.visible = true
	move_pointer(node)


func on_planet_clicked(node: int, button: int):
	var fac_tool = get_facility_tool()
	var road_tool = get_road_tool()
	
	if button == BUTTON_LEFT and road_tool == null:
		var facility: Facility = fsm.planet.get_facility(node)
		if facility != null:
			if button_group.get_pressed_button() == remove_button:
				var err = fsm.planet.builder.remove_facility(facility)
				if err != null:
					fsm.show_message(err, Consts.MESSAGE_ERROR)
				return
			elif facility != null and facility is City:
				fsm.push("edit_city", {"node": node})
				return
	
	if fac_tool != null:
		if button == BUTTON_LEFT:
			if fac_tool == Facilities.FAC_CITY:
				var costs = Facilities.FACILITY_COSTS[fac_tool]
				if costs > fsm.planet.taxes.budget:
					fsm.show_message("Not enough money (requires %d)" % costs, Consts.MESSAGE_ERROR)
				else:
					fsm.push("name_dialog", {"node": node})
			else:
				var fac_err = fsm.planet.add_facility(fac_tool, node, fac_tool, null)
				if fac_err[0] == null:
					fsm.show_message(fac_err[1], Consts.MESSAGE_ERROR)
		
		elif button == BUTTON_RIGHT:
			inspect_button.pressed = true
	else:
		if road_tool != null:
			if button == BUTTON_LEFT:
				if road_start_point >= 0:
					if clear_button.pressed:
						fsm.planet.remove_road(road_start_point, node, road_tool)
					else:
						var err = fsm.planet.add_road(road_start_point, node, road_tool)
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
					clear_button.pressed = false
	
	move_pointer(fsm.get_current_node())


func on_next_turn():
	on_planet_hovered(fsm.get_current_node())

func _on_ClearButton_pressed():
	on_planet_hovered(fsm.get_current_node())

func _on_tool_changed(_button):
	var curr_tool = get_facility_tool()
	var road_tool = get_road_tool()
	if curr_tool != null:
		road_start_point = -1
		clear_button.pressed = false
		
		var node = fsm.get_current_node()
		if node < 0:
			radius = 0
			coverage = 0
		else:
			radius = facility_functions.calc_range(curr_tool, fsm.planet.planet_data, node)
			coverage = facility_functions.calc_coverage(curr_tool, fsm.planet.planet_data, node)
		
		fsm.planet.clear_path()
		_update_range(node)
		
		fsm.update_build_info(curr_tool, -1)
		set_pointer(curr_tool, null)
	elif road_tool != null:
		radius = 0
		coverage = 0
		
		indicator.visible = false
		cov_indicator.visible = false
		fsm.update_build_info(road_tool, 1)
		on_planet_hovered(fsm.get_current_node())
		set_pointer(null, road_tool)
	else:
		road_start_point = -1
		indicator.visible = false
		cov_indicator.visible = false
		fsm.planet.clear_path()
		set_pointer(null, null)


func _update_range(node: int):
	if node < 0:
		indicator.visible = false
		cov_indicator.visible = false
		return
	
	if radius > 0:
		cells.clear()
		var temp_cells = fsm.planet.planet_data.get_in_radius(node, radius)
		for c in temp_cells:
			cells[c[0]] = c[1]
		
		var pos = fsm.planet.planet_data.get_position(node)
		indicator.translation = pos
		indicator.look_at(2 * pos, Vector3.UP)
		
		_draw_range(node, radius)
	else:
		indicator.visible = false
	
	
	if coverage > 0:
		var pos = fsm.planet.planet_data.get_position(node)
		cov_indicator.look_at(2 * pos, Vector3.UP)
		_draw_coverage(node, coverage)
	else:
		cov_indicator.visible = false


func _draw_range(center: int, new_radius):
	indicator.draw_range(fsm.planet.planet_data, center, cells, new_radius, Color.white)
	indicator.visible = true

func _draw_coverage(_center: int, new_coverage):
	cov_indicator.set_coverage(new_coverage)
	cov_indicator.visible = true


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		fsm.planet.remove_child(indicator)
		fsm.planet.remove_child(cov_indicator)
		fsm.planet.remove_child(pointer)
		indicator.queue_free()
		cov_indicator.queue_free()
		pointer.queue_free()


func _on_Inspect_pressed():
	clear_button.pressed = false
