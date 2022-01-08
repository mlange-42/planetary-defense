class_name BuildManager

const ROAD_CAPACITY = 25

var constants: LandUse

var network: RoadNetwork
var resources: ResourceManager
var planet_data = null
var taxes: TaxManager
var parent_node: Spatial


# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
func _init(consts: LandUse, net: RoadNetwork, resources: ResourceManager, planet_data, taxes: TaxManager, node: Spatial):
	self.constants = consts
	self.network = net
	self.resources = resources
	self.planet_data = planet_data
	self.taxes = taxes
	self.parent_node = node


func add_road(path: Array):
	if path.size() == 0:
		return "No path specified"
	
	var sum_cost = 0
	
	var warn = null
	for i in range(path.size()-1):
		if taxes.budget < sum_cost + Roads.ROAD_COSTS[Roads.ROAD_ROAD]:
			warn = "Road not completed - not enough money!"
			break
		
		var p1 = path[i]
		var p2 = path[i+1]
		if not network.points_connected(p1, p2):
			network.connect_points(p1, p2, ROAD_CAPACITY)
			sum_cost += Roads.ROAD_COSTS[Roads.ROAD_ROAD]
	
	taxes.budget -= sum_cost
	
	return warn


func remove_road(path: Array) -> bool:
	if path.size() == 0:
		return false
	
	for i in range(path.size()-1):
		var p1 = path[i]
		var p2 = path[i+1]
		if network.points_connected(p1, p2):
			network.disconnect_points(p1, p2)
	
	return true


func grow_city(city: City):
	var cost = Cities.city_growth_cost(city.radius)
	if cost > taxes.budget:
		return "Not enough money to grow city (requires %d)" % cost
	
	city.radius += 1
	city.update_cells(planet_data)
	taxes.budget -= cost
	
	return null


func add_facility(type: String, location: int, name: String):
	if not Facilities.FACILITY_SCENES.has(type):
		print("WARNING: no scene resource found for %s" % type)
		return [null, "WARNING: no scene resource found for %s" % type]
	
	if network.has_facility(location) or planet_data.get_node(location).is_occupied:
		return [null, "Location already occupied"]
	
	var costs = Facilities.FACILITY_COSTS[type]
	if costs > taxes.budget:
		return [null, "Not enough money (requires %d)" % costs]
	
	var facility: Facility = load(Facilities.FACILITY_SCENES[type]).instance()
	if not facility.can_build(planet_data, location):
		facility.queue_free()
		return [null, "Can't build this facility here"]
	
	facility.init(location, planet_data, type)
	
	taxes.budget -= costs
	
	return [add_facility_scene(facility, name), null]


func add_facility_scene(facility: Facility, name: String):
	network.add_facility(facility.node_id, facility)
	
	parent_node.add_child(facility)
	
	var info = planet_data.get_node(facility.node_id)
	facility.name = name
	facility.translation = info.position
	facility.look_at(2 * info.position, Vector3.UP)
	
	facility.on_ready(planet_data)
	
	return facility
	


# Use land_use = LandUse.LU_NONE to ignore specific requirements
func can_set_land_use(city: City, node: int, land_use: int, consider_veg_res: bool = false):
	if network.is_road(node) \
			or network.has_facility(node) \
			or planet_data.get_node(node).is_occupied:
		return [false, "Land is already occupied"]
	
	if not node in city.cells:
		return [false, "Land is not in range of %s" % city.name]
	
	if land_use == LandUse.LU_NONE:
		return [true, null]
	
	var req = city.has_landuse_requirements(land_use)
	if not req:
		return [false, "Requirements not met: %s" % LandUse.LU_REQUIREMENTS[land_use]]
	
	if not consider_veg_res:
		return [true, null]
	
	var veg = planet_data.get_node(node).vegetation_type
	var lu: Dictionary = constants.LU_MAPPING[land_use]
	if not veg in lu:
		return [false, "Land use %s not possible on %s" % [LandUse.LU_NAMES[land_use], LandUse.VEG_NAMES[veg]]]
	
	var extract_resource = LandUse.LU_RESOURCE[land_use]
	if extract_resource != null:
		var res_here = resources.resources.get(node, null)
		if res_here == null or res_here[0] != extract_resource:
			return [false, "Land use %s not possible without resource %s" % [LandUse.LU_NAMES[land_use], Resources.RES_NAMES[extract_resource]]]
	
	return [true, null]


func set_land_use(city: City, node: int, land_use: int):
	if land_use == LandUse.LU_NONE:
		if node in city.land_use:
			city.clear_land_use(node)
			planet_data.set_occupied(node, false)
			city.update_visuals(planet_data)
			return null
		else:
			return "Can't clear, land is not is use"
	
	var can_set_err = can_set_land_use(city, node, land_use, true)
	if not can_set_err[0]:
		return can_set_err[1]
	
	if city.workers() < LandUse.LU_WORKERS[land_use]:
		return "Not enough workers (requires %d)" % LandUse.LU_WORKERS[land_use]
	
	city.set_land_use(planet_data, node, land_use)
	planet_data.set_occupied(node, true)
	city.update_visuals(planet_data)
	
	return null
