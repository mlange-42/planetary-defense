class_name BuildManager

var network: RoadNetwork

func _init(net: RoadNetwork):
	self.network = net

func add_road(path: Array) -> bool:
	if path.size() == 0:
		return false
	
	for i in range(path.size()-1):
		var p1 = path[i]
		var p2 = path[i+1]
		if not network.points_connected(p1, p2):
			network.connect_points(p1, p2)
	
	return true
