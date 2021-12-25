extends Facility

onready var borders: ImmediateGeometry = $Borders

var cells: Array
var radius: int = 10
var workers: int = 1

func init(node: int, planet_data):
	.init(node, planet_data)
	cells = planet_data.get_in_radius(node, 10)

func on_ready(planet_data):
	_draw_borders(planet_data)
		
func _draw_borders(planet_data): 
	borders.clear()
	borders.begin(Mesh.PRIMITIVE_POINTS)
	
	borders.set_color(Color.white)
	
	cells = planet_data.get_in_radius(node_id, radius)
	for c in cells:
		if c[1] == radius:
			var p = planet_data.get_position(c[0])
			borders.add_vertex(self.to_local(p + Constants.DRAW_HEIGHT_OFFSET * p.normalized()))
	
	borders.end()
