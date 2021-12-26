extends Facility
class_name Port


func init(node: int, planet_data):
	.init(node, planet_data)
	
	planet_data.set_port(node, true)


func can_build(planet_data, node) -> bool:
	var nd = planet_data.get_node(node)
	
	if not nd.is_water:
		return false
	
	var neigh = planet_data.get_neighbors(node)
	for n in neigh:
		if not planet_data.get_node(n).is_water:
			return true
	
	return false
