extends Facility
class_name City

onready var city_sign: Spatial = $CitySign
onready var land_use_node: Spatial = $LandUse
onready var borders_mesh: RangeIndicator = $RangeIndicator

# key: node id, value: distance
var cells: Dictionary = {}
# key: node id, value: land use id
var land_use: Dictionary = {}
# key: node id, value: land use spatials
var land_use_nodes: Dictionary = {}

# key: node id, value: facility spatials
var facilities: Dictionary = {}

var radius: int = Cities.INITIAL_CITY_RADIUS

var _workers: int = Cities.INITIAL_CITY_POP setget , workers
var _population: int = Cities.INITIAL_CITY_POP

var commodity_weights: Array = [100, 100, 100, 0]
var auto_assign_workers: bool = true

var growth_stats: GrowthStats = GrowthStats.new()

class GrowthStats:
	var total: int = 0
	var supply_factor: int = 0
	var employment_factor: int = 0
	var space_factor: int = 0


func on_ready(planet_data):
	update_cells(planet_data)
	
	for node in land_use:
		add_land_use_node(planet_data, node, land_use[node])


func population() -> int:
	return _population


func workers() -> int:
	return _workers


func add_workers(num: int):
	_workers += num
	_population += num


func remove_workers(num: int):
	_workers -= num
	_population -= num


func free_workers(num: int):
	_workers += num


func assign_workers(num: int):
	_workers -= num


func save() -> Dictionary:
	var lu = []
	for node in land_use:
		lu.append([node, land_use[node]])
	
	var growth = {}
	growth["total"] = growth_stats.total
	growth["supply"] = growth_stats.supply_factor
	growth["employment"] = growth_stats.employment_factor
	growth["space"] = growth_stats.space_factor
	
	var dict = .save()
	
	dict["radius"] = radius
	dict["workers"] = _workers
	dict["commodity_weights"] = commodity_weights
	dict["auto_assign_workers"] = auto_assign_workers
	dict["land_use"] = lu
	dict["growth"] = growth
	
	return dict


func read(dict: Dictionary):
	.read(dict)
	
	radius = dict["radius"] as int
	_workers = dict["workers"] as int
	_population = _workers
	auto_assign_workers = dict["auto_assign_workers"] as bool
	
	var weigths = dict["commodity_weights"]
	for i in range(weigths.size()):
		commodity_weights[i] = weigths[i] as int
	
	for lu in dict["land_use"]:
		land_use[lu[0] as int] = lu[1] as int
		_population += LandUse.LU_WORKERS[lu[1] as int]
	
	var growth = dict.get("growth", null)
	if growth != null:
		growth_stats.total = growth["total"]
		growth_stats.supply_factor = growth["supply"]
		growth_stats.employment_factor = growth["employment"]
		growth_stats.space_factor = growth["space"]


func has_landuse_requirements(lu: int) -> bool:
	for req in LandUse.LU_REQUIREMENTS[lu]:
		var found = false
		for n in facilities:
			if facilities[n].type == req:
				found = true
				break
		
		if not found:
			return false
	
	return true


func set_land_use(planet_data, node: int, lu: int):
	land_use[node] = lu
	assign_workers(LandUse.LU_WORKERS[lu])
	add_land_use_node(planet_data, node, lu)


func clear_land_use(node: int):
	var lut = land_use[node]
	free_workers(LandUse.LU_WORKERS[lut])
	# warning-ignore:return_value_discarded
	land_use.erase(node)
	remove_land_use_node(node)


func add_land_use_node(planet_data, node: int, lu: int):
	var pos = planet_data.get_position(node)
	var child = LandUseNode.new(node, lu)
	land_use_nodes[node] = child
	
	land_use_node.add_child(child)
	child.look_at_from_position(pos, 2 * pos, Vector3.UP)


func remove_land_use_node(node: int):
	var child = land_use_nodes[node]
	land_use_node.remove_child(child)
	child.queue_free()
	# warning-ignore:return_value_discarded
	land_use_nodes.erase(node)


func update_cells(planet_data):
	cells.clear()
	var temp_cells = planet_data.get_in_radius(node_id, radius)
	for c in temp_cells:
		cells[c[0]] = c[1]
	
	update_visuals(planet_data)


func add_facility(node: int, facility: Facility):
	facilities[node] = facility

func remove_facility(node: int):
	assert(facilities.erase(node), "There is no a facility at node %s to remove" % node)


func update_visuals(planet_data):
	city_sign.set_text("%s (%d/%d)" % [name, workers(), population()])
	
	var flows_food = flows.get(Commodities.COMM_FOOD, [0, 0])
	var demand_food = sinks.get(Commodities.COMM_FOOD, 0)
	
	var flows_prod = flows.get(Commodities.COMM_PRODUCTS, [0, 0])
	var demand_prod = sinks.get(Commodities.COMM_PRODUCTS, 0)
	
	if flows_food[1] < demand_food:
		city_sign.set_warning_level(Consts.MESSAGE_ERROR)
	elif flows_prod[1] == 0 && demand_prod > 0:
		city_sign.set_warning_level(Consts.MESSAGE_ERROR)
	elif flows_prod[1] < demand_prod:
		city_sign.set_warning_level(Consts.MESSAGE_WARNING)
	else:
		city_sign.set_warning_level(Consts.MESSAGE_INFO)
	
	_draw_borders(planet_data)


func _draw_borders(planet_data):
	borders_mesh.draw_range(planet_data, node_id, cells, radius, Color.red)


func removed(planet):
	var fac = facilities.values()
	for f in fac:
		planet.builder.remove_facility(f)
