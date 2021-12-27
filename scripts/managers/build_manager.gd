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


func remove_road(path: Array) -> bool:
	if path.size() == 0:
		return false
	
	for i in range(path.size()-1):
		var p1 = path[i]
		var p2 = path[i+1]
		if network.points_connected(p1, p2):
			network.disconnect_points(p1, p2)
	
	return true


func add_facility(type: String, location: int, name: String):
	if not Constants.FACILITY_SCENES.has(type):
		print("WARNING: no scene resource found for %s" % type)
		return null
	
	if network.has_facility(location) or planet_data.get_node(location).is_occupied:
		return null
	
	var facility: Facility = load(Constants.FACILITY_SCENES[type]).instance()
	if not facility.can_build(planet_data, location):
		facility.queue_free()
		return null
	
	facility.init(location, planet_data)
	
	return add_facility_scene(facility, name)


func add_facility_scene(facility: Facility, name: String):
	network.add_facility(facility.node_id, facility)
	
	parent_node.add_child(facility)
	
	var info = planet_data.get_node(facility.node_id)
	facility.name = name
	facility.translation = info.position
	facility.look_at(2 * info.position, Vector3.UP)
	
	facility.on_ready(planet_data)
	
	return facility
	


# Use land_use = Constants.LU_NONE to ignore specific requirements
func can_set_land_use(city: City, node: int, land_use: int):
	if node in city.cells \
			and not network.is_road(node) \
			and not network.has_facility(node) \
			and not planet_data.get_node(node).is_occupied:
		
		return land_use == Constants.LU_NONE or city.has_landuse_requirements(land_use)
	else:
		return false


func set_land_use(city: City, node: int, land_use: int) -> bool:
	if land_use == Constants.LU_NONE:
		if node in city.land_use:
			var lut = city.land_use[node]
			city.workers += Constants.LU_WORKERS[lut]
			# warning-ignore:return_value_discarded
			city.land_use.erase(node)
			planet_data.set_occupied(node, false)
			city.update_visuals(planet_data)
			return true
		else:
			return false
	
	if not can_set_land_use(city, node, land_use):
		return false
	
	var veg = planet_data.get_node(node).vegetation_type
	var lu: Dictionary = constants.LU_MAPPING[land_use]
	
	if city.workers < Constants.LU_WORKERS[land_use]:
		return false
	
	if not veg in lu:
		return false
	
	planet_data.set_occupied(node, true)
	city.land_use[node] = land_use
	city.workers -= Constants.LU_WORKERS[land_use]
	city.update_visuals(planet_data)
	
	return true
