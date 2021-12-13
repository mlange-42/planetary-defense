extends Spatial

onready var planet: Planet = $Planet
onready var mouse: Mouse = $Mouse
onready var pointer: Spatial = $MousePointer


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
	pass


func _on_planet_exited():
	pass


func _on_planet_hovered(point: Vector3):
	var id = planet.nav.nav_all.get_closest_point(point)
	var node = planet.nav.get_node(id)
	pointer.translation = node.position


func _on_planet_clicked(point: Vector3):
	var id = planet.nav.nav_all.get_closest_point(point)
	if start_point >= 0:
		if planet.draw_path(start_point, id):
			start_point = id
	else:
		start_point = id
