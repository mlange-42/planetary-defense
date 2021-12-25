class_name BuildManager

const ROAD_CAPACITY = 25


var network: RoadNetwork
var planet_data = null
var parent_node: Spatial


# warning-ignore:shadowed_variable
func _init(net: RoadNetwork, planet_data, node: Spatial):
	self.network = net
	self.planet_data = planet_data
	self.parent_node = node


func add_road(path: Array) -> bool:
	if path.size() == 0:
		return false
	
	for i in range(path.size()-1):
		var p1 = path[i]
		var p2 = path[i+1]
		if not network.points_connected(p1, p2):
			network.connect_points(p1, p2, ROAD_CAPACITY)
	
	return true


func add_facility(type: String, location: int):
	if not Constants.FACILITY_SCENES.has(type):
		print("WARNING: no scene resource found for %s" % type)
		return
	
	var info = planet_data.get_node(location)
	
	if info.is_water:
		return
	
	if network.has_facility(location) or planet_data.get_node(location).is_occupied:
		return
	
	var facility: Facility = load(Constants.FACILITY_SCENES[type]).instance()
	facility.init(location, planet_data)
	network.add_facility(location, facility)
	
	parent_node.add_child(facility)
	
	facility.node_id = location
	facility.translation = info.position
	facility.look_at(2 * info.position, Vector3.UP)
	
	facility.on_ready(planet_data)
	
