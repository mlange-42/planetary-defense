class_name CityManager

var constants: LandUse
var planet = null

# warning-ignore:shadowed_variable
func _init(consts: LandUse, planet):
	self.constants = consts
	self.planet = planet

func pre_update():
	var facilities = planet.roads.facilities()
	
	for fid in facilities:
		var facility: Facility = facilities[fid]
		
		if facility is City:
			var city = facility as City
			pre_update_city(city)


func post_update():
	var facilities = planet.roads.facilities()
	
	var attractiveness = {}
	
	for fid in facilities:
		var facility: Facility = facilities[fid]
		if facility is City:
			var city = facility as City
			var attr = post_update_city(city)
			attractiveness[city] = attr
		
		facility.calc_is_supplied()
		if not facility.is_supplied:
			var name = facility.name if facility is City else facility.type
			var miss_text: String = "%s" % facility.get_missing_supply()
			miss_text = miss_text.substr(1, miss_text.length()-2)
			planet.messages.add_message(facility.node_id, "[u]%s[/u] not supplied\n  Missing: %s" % [name, miss_text], Consts.MESSAGE_WARNING)
	
	migrate(attractiveness)


func pre_update_city(city: City):
	city.sources.clear()
	city.sinks.clear()
	city.conversions.clear()
	
	var food_available = city.flows[Commodities.COMM_FOOD][1] if Commodities.COMM_FOOD in city.flows else 0
	food_available -= city.workers()
	
	var workers_to_feed = city.workers()
	
	var keys = city.land_use.keys()
	keys.shuffle()
	for node in keys:
		var lu = city.land_use[node]
		var data = planet.planet_data.get_node(node)
		
		var extract_resource = LandUse.LU_RESOURCE[lu]
		var lu_data = constants.LU_MAPPING[lu]
		var res_data = constants.LU_RESOURCES[lu]
		if not data.vegetation_type in lu_data:
			continue
		
		var workers = LandUse.LU_WORKERS[lu]
		
		var veg_data: LandUse.VegLandUse = lu_data[data.vegetation_type] \
					if extract_resource == null else res_data[extract_resource]
		
		if not _is_food_producer(veg_data):
			workers_to_feed += workers
			if food_available >= workers:
				food_available -= workers
			else:
				continue
		
		if veg_data.source != null:
			var amount = veg_data.source.amount if extract_resource == null \
							else planet.resources.can_extract_resource(node, extract_resource, veg_data.source.amount)
			if amount != 0:
				city.add_source(veg_data.source.commodity, amount)
		
		if veg_data.sink != null:
			city.add_sink(veg_data.sink.commodity, veg_data.sink.amount)
	
		if veg_data.conversion != null:
			var c: LandUse.Conversion = veg_data.conversion
			city.add_conversion(c.from, c.from_amount, c.to, c.to_amount, c.max_from_amount)
	
	city.add_sink(Commodities.COMM_FOOD, workers_to_feed)
	city.add_sink(Commodities.COMM_PRODUCTS, Cities.products_demand(city.population()))


func post_update_city(city: City) -> float:
	var food_available = city.flows.get(Commodities.COMM_FOOD, [0, 0])[1]
	food_available -= city.workers()
	
	var comm_produced = {}
	
	for comm in Commodities.COMM_ALL:
		comm_produced[comm] = city.flows.get(comm, [0, 0])[0]
	
	var all_workers_supplied = food_available >= 0
	
	var keys = city.land_use.keys()
	keys.shuffle()
	for node in keys:
		var lu = city.land_use[node]
		var data = planet.planet_data.get_node(node)
		
		var extract_resource = LandUse.LU_RESOURCE[lu]
		var lu_data = constants.LU_MAPPING[lu]
		var res_data = constants.LU_RESOURCES[lu]
		if not data.vegetation_type in lu_data:
			continue
		
		var workers = LandUse.LU_WORKERS[lu]
		
		var veg_data: LandUse.VegLandUse = lu_data[data.vegetation_type] \
					if extract_resource == null else res_data[extract_resource]
		
		if not _is_food_producer(veg_data):
			if food_available >= workers:
				food_available -= workers
			else:
				all_workers_supplied = false
		
		if veg_data.source != null:
			var comm = veg_data.source.commodity
			if comm_produced[comm] > 0:
				if extract_resource == null:
					comm_produced[comm] = max(0, comm_produced[comm] - veg_data.source.amount)
				else:
					var amount = min(veg_data.source.amount, comm_produced[comm])
					var realized_amount = planet.resources.extract_resource(node, extract_resource, amount)
					comm_produced[comm] -= realized_amount
					if not planet.resources.has_resource(node, extract_resource):
						planet.messages.add_message(node, "%s depleted in %s" % [Resources.RES_NAMES[extract_resource], city.name], Consts.MESSAGE_WARNING)
	
	var products_available = city.flows.get(Commodities.COMM_PRODUCTS, [0, 0])[1]
	var demand = Cities.products_demand(city.population())
	var share_satisfied = 1.0 if demand == 0 else clamp(products_available / float(demand), 0, 1)
	var space_growth = clamp(1.0 - (city.population() / float(city.cells.size())), 0, 1)
	var unemployment = 0.0 if city.population() == 0 else (city.workers() / float(city.population()))
	var employment_growth = clamp(1.0 - unemployment / Cities.UNEMPLOYMENT_NO_GROWTH, 0, 1)
	
	var attractiveness = share_satisfied * space_growth * employment_growth
	
	city.growth_stats.total = int(round(attractiveness * 100))
	city.growth_stats.supply_factor = int(round(share_satisfied * 100))
	city.growth_stats.space_factor = int(round(space_growth * 100))
	city.growth_stats.employment_factor = int(round(employment_growth * 100))
	
	if all_workers_supplied:
		if randf() < Cities.CITY_GROWTH_PROB * attractiveness:
			city.add_workers(1)
			city.update_visuals(planet.planet_data)
			planet.messages.add_message(city.node_id, "Population growth in [u]%s[/u]" % city.name, Consts.MESSAGE_INFO)
	else:
		city.growth_stats.total = 0
		city.growth_stats.supply_factor = 0
	
	return attractiveness


func _is_food_producer(lu: LandUse.VegLandUse) -> bool:
	if lu.source != null and lu.source.commodity == Commodities.COMM_FOOD:
		return true
	elif lu.conversion != null and lu.conversion.to == Commodities.COMM_FOOD:
		return true
	else:
		return false


func migrate(attractiveness: Dictionary):
	for city in attractiveness:
		for _i in city.workers():
			if randf() < Cities.UNEMPLOYED_MIGRATION_PROB:
				mirgate_inhabitant(city, attractiveness)


func mirgate_inhabitant(from: City, attractiveness: Dictionary):
	var curr_attr = attractiveness[from]
	var max_attr = 0
	var max_city = null
	
	for city in attractiveness:
		var attr = attractiveness[city]
		if city != from and attr > curr_attr and attr > max_attr:
			if planet.roads.path_exists(from.node_id, city.node_id):
				max_attr = attr
				max_city = city
	
	if max_city != null:
		from.remove_workers(1)
		max_city.add_workers(1)
		
		from.update_visuals(planet.planet_data)
		max_city.update_visuals(planet.planet_data)
		planet.messages.add_message(from.node_id, "Worker migrated from [u]%s[/u] to [u]%s[/u]" \
					% [from.name, max_city.name], Consts.MESSAGE_INFO)


func assign_workers(builder: BuildManager):
	var facilities = planet.roads.facilities()
	
	for fid in facilities:
		var facility = facilities[fid]
		if not facility is City:
			continue
		
		var city = facility as City
		assign_city_workers(city, builder)
		city.update_visuals(planet.planet_data)


func assign_city_workers(city: City, builder: BuildManager):
	if city.workers() <= 0 or not city.auto_assign_workers:
		return
	
	var sum_weights = sum(city.commodity_weights)
	var rel_weights = []
	rel_weights.resize(city.commodity_weights.size())
	for i in range(rel_weights.size()):
		if sum_weights > 0:
			rel_weights[i] = city.commodity_weights[i] / float(sum_weights)
		else:
			rel_weights[i] = 1.0 / rel_weights.size()
	
	var comm_map = {}
	for i in range(Commodities.COMM_ALL.size()):
		comm_map[Commodities.COMM_ALL[i]] = i
	
	while city.workers() > 0:
		var total_workers = city.workers()
		var comm_workers = []
		comm_workers.resize(Commodities.COMM_ALL.size())
		for i in range(comm_workers.size()):
			comm_workers[i] = 0
		
		for node in city.land_use:
			var lu: int = city.land_use[node]
			var workers: int = LandUse.LU_WORKERS[lu]
			var comm: String = LandUse.LU_OUTPUT[lu]
			var comm_id: int = comm_map[comm]
			comm_workers[comm_id] += workers
			total_workers += workers
		
		var target_workers = []
		var max_diff = 0
		var best_commodity = -1
		target_workers.resize(Commodities.COMM_ALL.size())
		for i in range(Commodities.COMM_ALL.size()):
			target_workers[i] = total_workers * rel_weights[i]
			var diff = target_workers[i] - comm_workers[i]
			if diff > max_diff:
				max_diff = diff
				best_commodity = i
		
		if best_commodity < 0:
			return
		
		var max_amount_dist = [0, 9999]
		var max_solution = [-1, -1]
		
		for node in city.cells:
			if not builder.can_set_land_use(city, node, LandUse.LU_NONE)[0]:
				continue
			
			var veg = planet.planet_data.get_node(node).vegetation_type
			var res = planet.resources.resources.get(node, null)
			
			var lu_options: Dictionary = constants.VEG_MAPPING.get(veg, {})
			var res_options: Dictionary = constants.RES_MAPPING.get(res[0], {}) if res != null else {}
			for key in res_options:
				lu_options[key] = res_options[key]
			
			for lu in lu_options:
				if lu_options[lu] == null:
					continue
				if comm_map[LandUse.LU_OUTPUT[lu]] == best_commodity \
						and LandUse.LU_WORKERS[lu] <= city.workers() \
						and city.has_landuse_requirements(lu):
					var opt: LandUse.VegLandUse = lu_options[lu]
					var amount = opt.source.amount if opt.source != null else 0
					
					var dist = city.cells[node]
					if amount > max_amount_dist[0] \
							or (amount == max_amount_dist[0] and dist < max_amount_dist[1]):
						max_amount_dist = [amount, dist]
						max_solution = [node, lu]
			
		if max_solution[0] < 0:
			break
		if builder.set_land_use(city, max_solution[0], max_solution[1]) != null:
			print("Warning: unable to auto-assign land use")
			break
	


func sum(arr):
	var s = 0
	for v in arr:
		s += v
	return s
