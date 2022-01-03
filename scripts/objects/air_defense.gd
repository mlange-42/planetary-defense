extends Facility
class_name AirDefense

var radius: int

onready var pole: CSGBox = $Pole
onready var ring: ImmediateGeometry = $RingGeometry

var cells: Dictionary = {}

func _ready():
	radius = Facilities.FACILITY_RADIUS[type]
	
	var material = SpatialMaterial.new()
	material.emission_enabled = true
	pole.material = material


func on_ready(planet_data):
	var temp_cells = planet_data.get_in_radius(node_id, radius)
	for c in temp_cells:
		cells[c[0]] = c[1]
	
	_draw_cells(planet_data)


func calc_is_supplied():
	.calc_is_supplied()
	var col = Color.green if is_supplied else Color.red
	pole.material.albedo_color = col
	pole.material.emission = col


func can_build(planet_data, node) -> bool:
	return not planet_data.get_node(node).is_water


func _draw_cells(planet_data): 
	ring.clear()
	ring.begin(Mesh.PRIMITIVE_LINES)
	
	ring.set_color(Color.cyan)
	
	for c in cells:
		if cells[c] == radius:
			var p = planet_data.get_position(c)
			ring.add_vertex(self.to_local(p))
			ring.add_vertex(self.to_local(p + 0.25 * p.normalized()))
	
	ring.end()
