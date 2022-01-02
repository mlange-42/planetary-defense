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


func add_road(path: Array) -> bool:
	if path.size() == 0:
		return false
	
	var sum_cost = 0
	
	for i in range(path.size()-1):
		if taxes.budget < sum_cost + Consts.ROAD_COSTS:
			break
		
		var p1 = path[i]
		var p2 = path[i+1]
		if not network.points_connected(p1, p2):
			network.connect_points(p1, p2, ROAD_CAPACITY)
			sum_cost += Consts.ROAD_COSTS
	
	taxes.budget -= sum_cost
	
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
	
	facility.init(location, planet_data)
	
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
func can_set_land_use(city: City, node: int, land_use: int):
	if node in city.cells \
			and not network.is_road(node) \
			and not network.has_facility(node) \
			and not planet_data.get_node(node).is_occupied:
		
		if land_use == LandUse.LU_NONE:
			return [true, null]
		
		var req = city.has_landuse_requirements(land_use)
		if req:
			return [true, null]
		else:
			return [false, "Requirements not met: %s" % LandUse.LU_REQUIREMENTS[land_use]]
	else:
		return [false, "Land is already occupied"]


func set_land_use(city: City, node: int, land_use: int):
	if land_use == LandUse.LU_NONE:
		if node in city.land_use:
			var lut = city.land_use[node]
			city.workers += LandUse.LU_WORKERS[lut]
			# warning-ignore:return_value_discarded
			city.land_use.erase(node)
			planet_data.set_occupied(node, false)
			city.update_visuals(planet_data)
			return null
		else:
			return "Can't clear, land is not is use"
	
	var can_set_err = can_set_land_use(city, node, land_use)
	if not can_set_err[0]:
		return can_set_err[1]
	
	var res_here = resources.resources.get(node, null)
	var extract_resource = LandUse.LU_RESOURCE[land_use]
	var veg = planet_data.get_node(node).vegetation_type
	var lu: Dictionary = constants.LU_MAPPING[land_use]
	
	if city.workers < LandUse.LU_WORKERS[land_use]:
		return "Not enough workers (requires %d)" % LandUse.LU_WORKERS[land_use]
	
	if not veg in lu:
		return "Vegetation type %s can't be used for %s" % [LandUse.VEG_NAMES[veg], LandUse.LU_NAMES[land_use]]
	
	if extract_resource != null:
		if res_here == null or res_here[0] != extract_resource:
			return "Resource %s not available here" % Resources.RES_NAMES[extract_resource]
	
	planet_data.set_occupied(node, true)
	city.land_use[node] = land_use
	city.workers -= LandUse.LU_WORKERS[land_use]
	city.update_visuals(planet_data)
	
	return null
