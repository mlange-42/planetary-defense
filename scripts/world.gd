extends Spatial

onready var planet: Planet = $Planet
onready var mouse: Mouse = $Mouse
onready var pointer: Spatial = $MousePointer
onready var gui: Gui = $GUI


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
	var id = planet.planet_data.get_closest_point(point)

	var node = planet.planet_data.get_node(id)
	pointer.translation = node.position

	gui.on_planet_hovered(planet, id)


func _on_planet_clicked(point: Vector3, button: int):
	var id = planet.planet_data.get_closest_point(point)
	
	gui.on_planet_clicked(planet, id, button)


func _show_info(id: int):
	var facility: Facility = planet.get_facility(id)
	if facility == null:
		_hide_info()
		return
	
	var text = "%s (%d)\nFlows:\n" % [facility.name, id]
	
	var flows = facility.flows
	for comm in flows:
		text += "  %s %d/%d -> X -> %d/%d\n" % \
				[comm, flows[comm][1], facility.sinks.get(comm, 0), flows[comm][0], facility.sources.get(comm, 0)]
	
	if facility.conversions.size() > 0:
		text += "Conversions:\n"
		for from_to in facility.conversions:
			var amounts = facility.conversions[from_to]
			text += "  %d %s -> %d %s" % \
					[amounts[0], from_to[0], amounts[1], from_to[1]]
			
	
	gui.show_info(text)


func _hide_info():
	gui.hide_info()


func _on_next_turn():
	planet.next_turn()
