extends Spatial

export (String) var save_name = "default"

onready var planet: Planet
onready var mouse: Mouse = $Mouse
onready var pointer: Spatial = $MousePointer
onready var gui: Gui = $GUI
onready var cam_control: CameraControl = $CameraControl

# Array of Dictionaries to override parameters
var planet_params = []

var hover_id: int = -1

func _init():
	pass


func _ready():
	get_tree().set_auto_accept_quit(false)
	
	randomize()
	
	planet = Planet.new(planet_params)
	planet.save_name = save_name
	add_child(planet)
	
	gui.planet = planet
	cam_control.planet_radius = planet.radius
	cam_control.init()
	
	# warning-ignore:return_value_discarded
	mouse.connect("planet_entered", self, "_on_planet_entered")
	# warning-ignore:return_value_discarded
	mouse.connect("planet_exited", self, "_on_planet_exited")
	# warning-ignore:return_value_discarded
	mouse.connect("planet_hovered", self, "_on_planet_hovered")
	# warning-ignore:return_value_discarded
	mouse.connect("planet_clicked", self, "_on_planet_clicked")
	
	# warning-ignore:return_value_discarded
	planet.connect("budget_changed", self, "_on_budget_changed")
	
	# warning-ignore:return_value_discarded
	gui.connect("go_to_location", self, "_on_go_to_location")
	
	planet.init()
	gui.init()


func _on_planet_entered(point: Vector3):
	pointer.visible = true
	var id = planet.planet_data.get_closest_point(point)
	gui.on_planet_entered(id)


func _on_planet_exited():
	pointer.visible = false
	gui.on_planet_exited()


func _on_planet_hovered(point: Vector3):
	var id = planet.planet_data.get_closest_point(point)
	
	if id != hover_id:
		var node = planet.planet_data.get_node(id)
		pointer.look_at_from_position(node.position, 2 * node.position, Vector3.UP)
		gui.on_planet_hovered(id)
		
		hover_id = id


func _on_planet_clicked(point: Vector3, button: int):
	var id = planet.planet_data.get_closest_point(point)
	
	gui.on_planet_clicked(id, button)


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


func _on_budget_changed(_taxes: TaxManager):
	gui.update_finances()


func _on_go_to_location(location: Vector3):
	cam_control.go_to(location)
