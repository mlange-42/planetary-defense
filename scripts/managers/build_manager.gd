class_name BuildManager

var constants: LandUse
var facility_functions: Facilities.FacilityFunctions = Facilities.FacilityFunctions.new()

var planet = null
var parent_node: Spatial

var city_names: Dictionary = {}

# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
func _init(consts: LandUse, planet, node: Spatial):
	self.constants = consts
	self.planet = planet
	self.parent_node = node


func add_road(path: Array, road_type: int):
	if path.size() == 0:
		return "No path specified"
	
	var mode = Network.TYPE_MODES[road_type]
	
	var sum_cost = 0
	
	var capacity = Network.TYPE_CAPACITY[road_type]
	var cost = Network.TYPE_COSTS[road_type]
	var t_cost = Network.TYPE_TRANSPORT_COST_1000[road_type]
	
	var warn = null
	for i in range(path.size()-1):
		if planet.taxes.budget < sum_cost + Network.TYPE_COSTS[road_type]:
			warn = "Road not completed - not enough money!"
			break
		
		var p1 = Network.to_mode_id(path[i], mode)
		var p2 = Network.to_mode_id(path[i+1], mode)
		if not planet.roads.points_connected(p1, p2):
			var conn = false
			for block in Network.MODE_BLOCK[mode]:
				var pp1 = Network.to_mode_id(p1, block)
				var pp2 = Network.to_mode_id(p2, block)
				if planet.roads.points_connected(pp1, pp2):
					conn = true
					break
			
			if not conn:
				planet.roads.connect_points(p1, p2, road_type, capacity, t_cost)
				sum_cost += cost
	
	planet.taxes.budget -= sum_cost
	
	return warn


func remove_road(path: Array, mode: int) -> bool:
	if path.size() == 0:
		return false
	
	for i in range(path.size()-1):
		var p1 = path[i]
		var p2 = path[i+1]
		
		var pp1 = Network.to_mode_id(p1, mode)
		var pp2 = Network.to_mode_id(p2, mode)
		if planet.roads.points_connected(pp1, pp2):
			planet.roads.disconnect_points(pp1, pp2)
	
	return true


func grow_city(city: City):
	var cost = Cities.city_growth_cost(city.radius)
	if cost > planet.taxes.budget:
		return "Not enough money to grow city (requires %d)" % cost
	
	city.radius += 1
	city.update_cells(planet.planet_data)
	planet.taxes.budget -= cost
	
	return null


func city_name_available(name: String) -> bool:
	return not city_names.has(name)


func add_facility(type: String, location: int, name: String, owner):
	if not Facilities.FACILITY_SCENES.has(type):
		print("WARNING: no scene resource found for %s" % type)
		return [null, "WARNING: no scene resource found for %s" % type]
	
	if planet.roads.has_facility(location) or planet.planet_data.get_node(location).is_occupied:
		return [null, "Location already occupied"]
	
	var costs = Facilities.FACILITY_COSTS[type]
	if costs > planet.taxes.budget:
		return [null, "Not enough money (requires %d)" % costs]
	
	if not facility_functions.can_build(type, planet.planet_data, location, owner):
		return [null, "Can't build this facility here"]
	
	var facility: Facility = load(Facilities.FACILITY_SCENES[type]).instance()
	
	facility.init(location, planet, type)
	
	planet.taxes.budget -= costs
	
	return [add_facility_scene(facility, name), null]


func add_facility_scene(facility: Facility, name: String):
	planet.roads.add_facility(facility.node_id, facility)
	
	parent_node.add_child(facility)
	
	var info = planet.planet_data.get_node(facility.node_id)
	facility.name = name
	facility.translation = info.position
	facility.look_at(2 * info.position, Vector3.UP)
	
	facility.on_ready(planet.planet_data)
	
	if facility is City:
		city_names[facility.name] = true
	
	return facility


func remove_facility(facility: Facility):
	if facility is City:
		var city: City = facility as City
		if city.population() > 1 or not city.land_use.empty():
			return "Can't remove city with population > 1\nor active land use!"
	
	if facility.city_node_id >= 0:
		var owner: City = planet.roads.get_facility(facility.city_node_id) as City
		owner.remove_facility(facility.node_id)
	
	planet.roads.remove_facility(facility.node_id)
	facility.removed(planet)
	
	parent_node.remove_child(facility)
	facility.queue_free()
	
	return null


# Use land_use = LandUse.LU_NONE to ignore specific requirements
func can_set_land_use(city: City, node: int, land_use: int, consider_veg_res: bool = false):
	if planet.roads.is_road(node) \
			or planet.roads.has_facility(node) \
			or planet.planet_data.get_node(node).is_occupied:
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
	
	var veg = planet.planet_data.get_node(node).vegetation_type
	var lu: Dictionary = constants.LU_MAPPING[land_use]
	if not veg in lu:
		return [false, "Land use %s not possible on %s" % [LandUse.LU_NAMES[land_use], LandUse.VEG_NAMES[veg]]]
	
	var extract_resource = LandUse.LU_RESOURCE[land_use]
	if extract_resource != null:
		var res_here = planet.resources.resources.get(node, null)
		if res_here == null or res_here[0] != extract_resource:
			return [false, "Land use %s not possible without resource %s" % [LandUse.LU_NAMES[land_use], Resources.RES_NAMES[extract_resource]]]
	
	return [true, null]


func set_land_use(city: City, node: int, land_use: int):
	if land_use == LandUse.LU_NONE:
		if node in city.land_use:
			city.clear_land_use(node)
			planet.planet_data.set_occupied(node, false)
			city.update_visuals(planet.planet_data)
			return null
		else:
			return "Can't clear, land is not is use"
	
	var can_set_err = can_set_land_use(city, node, land_use, true)
	if not can_set_err[0]:
		return can_set_err[1]
	
	if city.workers() < LandUse.LU_WORKERS[land_use]:
		return "Not enough workers (requires %d)" % LandUse.LU_WORKERS[land_use]
	
	city.set_land_use(planet.planet_data, node, land_use)
	planet.planet_data.set_occupied(node, true)
	city.update_visuals(planet.planet_data)
	
	return null
