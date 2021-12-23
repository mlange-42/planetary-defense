extends Facility

var cells: Array

func init(node: int, planet_data):
	.init(node, planet_data)
	cells = planet_data.get_in_radius(node, 10)
	

func on_ready(planet_data):
	var s = 0.05
	var mat = SpatialMaterial.new()
	
	for cell in cells:
		var marker = CSGBox.new()
		marker.width = s
		marker.height = s
		marker.depth = s
		marker.material_override = mat
		
		marker.translation = self.to_local(planet_data.get_position(cell[0]))
		
		add_child(marker)
