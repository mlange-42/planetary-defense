extends Facility
class_name Port

func init(node: int, planet, type: String):
	.init(node, planet, type)
	
	planet.planet_data.set_port(node, true)
	
	var p1 = Network.to_mode_id(self.node_id, Network.M_ROADS)
	var p2 = Network.to_mode_id(self.node_id, Network.M_SEA)
	planet.roads.connect_points(p1, p2, Network.T_ROAD, Network.TYPE_CAPACITY[Network.T_ROAD])


func removed(planet):
	planet.planet_data.set_port(node_id, false)
	
	var p1 = Network.to_mode_id(self.node_id, Network.M_ROADS)
	var p2 = Network.to_mode_id(self.node_id, Network.M_SEA)
	planet.roads.disconnect_points(p1, p2)
	
	var neigh = planet.roads.network.get_node(node_id)
	if neigh != null:
		for n in neigh[1]:
			planet.roads.disconnect_points(node_id, n)
