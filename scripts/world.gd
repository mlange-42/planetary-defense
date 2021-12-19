extends Spatial

onready var planet: Planet = $Planet
onready var mouse: Mouse = $Mouse
onready var pointer: Spatial = $MousePointer
onready var gui: Gui = $GUI


var start_point: int = -1


func _ready():
	# warning-ignore:return_value_discarded
	mouse.connect("planet_entered", self, "_on_planet_entered")
	# warning-ignore:return_value_discarded
	mouse.connect("planet_exited", self, "_on_planet_exited")
	# warning-ignore:return_value_discarded
	mouse.connect("planet_hovered", self, "_on_planet_hovered")
	# warning-ignore:return_value_discarded
	mouse.connect("planet_clicked", self, "_on_planet_clicked")


func _on_planet_entered(_point: Vector3):
	pointer.visible = true


func _on_planet_exited():
	pointer.visible = false


func _on_planet_hovered(point: Vector3):
	var id = planet.nav.nav_all.get_closest_point(point)
	var node = planet.nav.get_node(id)
	pointer.translation = node.position
	
	var sel_tool = gui.get_selected_tool()
	if sel_tool == "Road":
		if start_point >= 0:
			planet.draw_path(start_point, id)
	else:
		start_point = -1


func _on_planet_clicked(point: Vector3, button: int):
	var id = planet.nav.nav_all.get_closest_point(point)
	var sel_tool = gui.get_selected_tool()
	if sel_tool == "Road":
		if button == BUTTON_LEFT:
			if start_point >= 0:
				planet.add_road(start_point, id)
				start_point = -1
				planet.clear_path()
			else:
				start_point = id
		else:
			start_point = -1
			planet.clear_path()
	elif sel_tool != null:
		if button == BUTTON_LEFT:
			planet.add_facility(sel_tool, id)


func _on_next_turn():
	planet.next_turn()
