extends GuiState
class_name BuildState

var names = CityNames.GERMAN

onready var name_edit: LineEdit = find_node("CityName")
onready var buttons: Container = find_node("Buttons")

var button_group: ButtonGroup

func _ready():
	set_random_name()
	
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
				fsm.pop()
			else:
				fsm.show_message(fac_err[1], Consts.MESSAGE_ERROR)
		else:
			fsm.show_message("No city name given!", Consts.MESSAGE_ERROR)
