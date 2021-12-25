class_name BuildManager

const ROAD_CAPACITY = 25

var constants: Constants

var network: RoadNetwork
var planet_data = null
var parent_node: Spatial


# warning-ignore:shadowed_variable
func _init(consts: Constants, net: RoadNetwork, planet_data, node: Spatial):
	self.constants = consts
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


func set_land_use(city: City, node: int, land_use: int):
	if not node in city.cells:
		return
	if network.is_road(node):
		return
	if network.has_facility(node):
		return
	
	if land_use == Constants.LU_NONE:
		if city.land_use.erase(node):
			planet_data.set_occupied(node, false)
			city.update_visuals(planet_data)
		return
	
	if planet_data.get_node(node).is_occupied:
		return
	
	var veg = planet_data.get_node(node).vegetation_type
	var lu: Constants.LandUse = constants.LU_MAPPING[land_use]
	
	if not veg in lu.vegetations:
		return
	
	planet_data.set_occupied(node, true)
	city.land_use[node] = land_use
	city.update_visuals(planet_data)
	
	print("Set land use %s (%d): %s" % [city, node, land_use])
