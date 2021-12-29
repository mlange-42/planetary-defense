extends Spatial

export (String) var save_name = "default"

onready var planet: Planet
onready var mouse: Mouse = $Mouse
onready var pointer: Spatial = $MousePointer
onready var gui: Gui = $GUI
onready var cam_control: CameraControl = $CameraControl

# Array of Dictionaries to override parameters
var planet_params = []

func _init():
	pass


func _ready():
	planet = Planet.new(planet_params)
	planet.save_name = save_name
	add_child(planet)
	
	gui.planet = planet
	cam_control.planet_radius = planet.radius
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
	
	planet.init()


func _on_planet_entered(_point: Vector3):
	pointer.visible = true


func _on_planet_exited():
	pointer.visible = false


func _on_planet_hovered(point: Vector3):
	var id = planet.planet_data.get_closest_point(point)

	var node = planet.planet_data.get_node(id)
	pointer.translation = node.position
	pointer.look_at(2 * node.position, Vector3.UP)

	gui.on_planet_hovered(id)


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


func _on_budget_changed(taxes: TaxManager):
	gui.set_budget_taxes_maintenance(taxes)
