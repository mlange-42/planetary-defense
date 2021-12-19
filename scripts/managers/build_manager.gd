class_name BuildManager

const ROAD_CAPACITY = 25

const SCENES = {
	"Town": "res://scenes/objects/town.tscn",
	"Mine": "res://scenes/objects/mine.tscn",
	"Factory": "res://scenes/objects/factory.tscn",
}


var network: RoadNetwork
var navigation: NavManager
var parent_node: Spatial


func _init(net: RoadNetwork, nav: NavManager, node: Spatial):
	self.network = net
	self.navigation = nav
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
	if not SCENES.has(type):
		print("WARNING: no scene resource found for %s" % type)
		return
	
	var info: NavManager.NodeData = navigation.get_node(location)
	
	if info.is_water:
		return
	
	if network.has_facility(location):
		return
	
	var facility: Facility = load(SCENES[type]).instance()
	network.add_facility(location, facility)
	
	parent_node.add_child(facility)
	
	facility.node_id = location
	facility.translation = info.position
	facility.look_at(2 * info.position, Vector3.UP)
	
