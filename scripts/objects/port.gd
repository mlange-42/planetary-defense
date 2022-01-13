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
