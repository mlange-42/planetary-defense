extends GuiState
class_name NameDialogState

var names = CityNames.GERMAN

onready var name_edit: LineEdit = find_node("CityName")

var node: int

func init(the_fsm: Gui, args: Dictionary):
	.init(the_fsm, args)
	
	node = args["node"]


func _ready():
	set_random_name()
	name_edit.grab_focus()


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


func build_city():
	if name_edit.text.empty():
		fsm.show_message("No city name given!", Consts.MESSAGE_ERROR)
	else:
		var name = name_edit.text
		if not fsm.planet.builder.city_name_available(name):
			fsm.show_message("There is already a city named %s!" % name, Consts.MESSAGE_ERROR)
			return
		
		var fac_err = fsm.planet.add_facility(Facilities.FAC_CITY, node, name)
		if fac_err[0] == null:
			fsm.show_message(fac_err[1], Consts.MESSAGE_ERROR)
		
		fsm.pop()


func _on_BackButton_pressed():
	fsm.pop()


func _on_ConfirmName_pressed():
	build_city()

func _on_CityName_text_entered(_new_text):
	build_city()


func _on_CancelName_pressed():
	fsm.pop()


