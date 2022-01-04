extends GuiState
class_name BuildState

var names = CityNames.GERMAN

onready var name_edit: LineEdit = find_node("CityName")
onready var buttons: Container = find_node("Buttons")
onready var veg_label: Label = find_node("VegetationLabel")

var indicator: ImmediateGeometry

var button_group: ButtonGroup

var cells: Array = []
var radius: int = 0


func _ready():
	set_random_name()
	
	indicator = ImmediateGeometry.new()
	indicator.material_override = preload("res://assets/materials/unlit_vertex_color.tres")
	fsm.planet.add_child(indicator)
	
	button_group = ButtonGroup.new()
	
	for fac in Facilities.FACILITY_IN_CITY:
		if not Facilities.FACILITY_IN_CITY[fac]:
			var button := FacilityButton.new()
			button.facility = fac
			button.text = fac
			button.group = button_group
			
			var evt = InputEventKey.new()
			evt.pressed = true
			evt.scancode = Facilities.FACILITY_KEYS[fac]
			button.shortcut = ShortCut.new()
			button.shortcut.shortcut = evt
			
			buttons.add_child(button)


func state_entered():
	indicator.visible = true


func state_exited():
	indicator.visible = false


func set_random_name():
	name_edit.text = names[randi() % names.size()]


func get_facility_tool():
	var button = button_group.get_pressed_button()
	if button == null:
		return null
	else:
		return button.facility


func _on_Back_pressed():
	fsm.pop()


func on_planet_entered(_node: int):
	indicator.visible = radius > 0


func on_planet_exited():
	indicator.visible = false
	veg_label.text = fsm.get_node_info(-1)

func on_planet_hovered(node: int):
	veg_label.text = fsm.get_node_info(node)
	
	var curr_tool = get_facility_tool()
	if curr_tool == null:
		return
	
	var rad = Facilities.FACILITY_RADIUS[curr_tool]
	_update_range(node, rad)


func on_planet_clicked(node: int, button: int):
	if button == BUTTON_LEFT:
		var curr_tool = get_facility_tool()
		if curr_tool == null:
			return
		
		var is_city = curr_tool == Facilities.FAC_CITY
		if not is_city or not name_edit.text.empty():
			var name = name_edit.text if is_city else curr_tool
			var fac_err = fsm.planet.add_facility(curr_tool, node, name)
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


func _update_range(node: int, new_radius: int):
	if new_radius == 0:
		indicator.visible = false
	else:
		cells.clear()
		var temp_cells = fsm.planet.planet_data.get_in_radius(node, new_radius)
		for c in temp_cells:
			if c[1] == new_radius:
				cells.append(c[0])
		
		var pos = fsm.planet.planet_data.get_position(node)
		indicator.translation = pos
		indicator.look_at(2 * pos, Vector3.UP)
		
		_draw_range()
	
	radius = new_radius


func _draw_range():
	indicator.visible = true
	
	indicator.clear()
	indicator.begin(Mesh.PRIMITIVE_POINTS)
	
	indicator.set_color(Color.white)
	
	for c in cells:
		var p = fsm.planet.planet_data.get_position(c)
		indicator.add_vertex(indicator.to_local(p + 2 * Consts.DRAW_HEIGHT_OFFSET * p.normalized()))
	
	indicator.end()


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		fsm.planet.remove_child(indicator)
		indicator.queue_free()
