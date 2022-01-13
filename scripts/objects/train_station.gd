extends Facility
class_name TrainStation

func init(node: int, planet, type: String):
	.init(node, planet, type)
	
	var p1 = Network.to_mode_id(self.node_id, Network.M_ROADS)
	var p2 = Network.to_mode_id(self.node_id, Network.M_RAIL)
	planet.roads.connect_points(p1, p2, Network.T_RAIL, Network.TYPE_CAPACITY[Network.T_RAIL])


func removed(planet):
	var p1 = Network.to_mode_id(self.node_id, Network.M_ROADS)
	var p2 = Network.to_mode_id(self.node_id, Network.M_RAIL)
	planet.roads.disconnect_points(p1, p2)
