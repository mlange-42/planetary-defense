extends Facility
class_name Port

func init(node: int, planet_data, type: String):
	.init(node, planet_data, type)
	
	planet_data.set_port(node, true)


func removed(planet):
	planet.planet_data.set_port(node_id, false)
	
	var neigh = planet.roads.network.get_node(node_id)
	if neigh != null:
		for n in neigh[1]:
			planet.roads.disconnect_points(node_id, n)


func can_build(planet_data, node) -> bool:
	var nd = planet_data.get_node(node)
	
	if not nd.is_water:
		return false
	
	var neigh = planet_data.get_neighbors(node)
	for n in neigh:
		if not planet_data.get_node(n).is_water:
			return true
	
	return false
