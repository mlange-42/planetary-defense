class_name CityManager

var constants: Constants
var network: RoadNetwork
var planet_data = null

# warning-ignore:shadowed_variable
func _init(consts: Constants, net: RoadNetwork, planet_data):
	self.constants = consts
	self.network = net
	self.planet_data = planet_data

func pre_update():
	var facilities = network.facilities
	
	for fid in facilities:
		var facility = facilities[fid]
		if not facility is City:
			continue
		
		var city = facility as City
		city.sources.clear()
		city.sinks.clear()
		city.conversions.clear()
		
		var food_available = city.flows[Constants.COMM_FOOD][1] if Constants.COMM_FOOD in city.flows else 0
		food_available -= city.workers
		
		var workers_to_feed = city.workers
		var products_required = city.workers
		
		var keys = city.land_use.keys()
		keys.shuffle()
		for node in keys:
			var lu = city.land_use[node]
			var data = planet_data.get_node(node)
			
			var lu_data = constants.LU_MAPPING[lu]
			if not data.vegetation_type in lu_data:
				continue
			
			var workers = Constants.LU_WORKERS[lu]
			products_required += workers
			
			var veg_data: Constants.VegLandUse = lu_data[data.vegetation_type]
			if veg_data.source == null or veg_data.source.commodity != Constants.COMM_FOOD:
				workers_to_feed += workers
				if food_available >= workers:
					food_available -= workers
				else:
					continue
			
			if veg_data.source != null:
				city.add_source(veg_data.source.commodity, veg_data.source.amount)
			
			if veg_data.sink != null:
				city.add_sink(veg_data.sink.commodity, veg_data.sink.amount)
		
			if veg_data.conversion != null:
				var c: Constants.Conversion = veg_data.conversion
				city.add_conversion(c.from, c.from_amount, c.to, c.to_amount, c.max_from_amount)
		
		city.add_sink(Constants.COMM_FOOD, workers_to_feed)
		city.add_sink(Constants.COMM_PRODUCTS, products_required / 2)


func post_update():
	var facilities = network.facilities
	
	for fid in facilities:
		var facility = facilities[fid]
		if not facility is City:
			continue
		
		var city = facility as City
		
		while city.land_use.size() * 2 > city.cells.size():
			city.radius += 1
			city.update_cells(planet_data)
		
		var food_available = city.flows[Constants.COMM_FOOD][1] if Constants.COMM_FOOD in city.flows else 0
		food_available -= city.workers
		
		var total_workers = city.workers
		
		var all_workers_supplied = food_available >= 0
		
		for node in city.land_use:
			var lu = city.land_use[node]
			var data = planet_data.get_node(node)
			
			var lu_data: Dictionary = constants.LU_MAPPING[lu]
			if not data.vegetation_type in lu_data:
				continue
			
			var workers = Constants.LU_WORKERS[lu]
			total_workers += workers
			
			var veg_data: Constants.VegLandUse = lu_data[data.vegetation_type]
			if veg_data.source == null or veg_data.source.commodity != Constants.COMM_FOOD:
				if food_available >= workers:
					food_available -= workers
				else:
					all_workers_supplied = false
					break
		
		var products_available = city.flows[Constants.COMM_PRODUCTS][1] if Constants.COMM_PRODUCTS in city.flows else 0
		var share_satisfied = clamp(products_available / float(total_workers / 2), 0, 1)
		
		if all_workers_supplied:
			print("%s: food satified, products %d%%" % [city.name, round(share_satisfied*100)])
			if randf() < Constants.CITY_GROWTH_PROB * share_satisfied:
				city.workers += 1
				city.update_visuals(planet_data)


func assign_workers(builder: BuildManager):
	var facilities = network.facilities
	
	for fid in facilities:
		var facility = facilities[fid]
		if not facility is City:
			continue
		
		var city = facility as City
		assign_city_workers(city, builder)
		city.update_visuals(planet_data)


func assign_city_workers(city: City, builder: BuildManager):
	if city.workers <= 0 or not city.auto_assign_workers:
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
	for i in range(Constants.COMM_ALL.size()):
		comm_map[Constants.COMM_ALL[i]] = i
	
	while city.workers > 0:
		var total_workers = city.workers
		var comm_workers = []
		comm_workers.resize(Constants.COMM_ALL.size())
		for i in range(comm_workers.size()):
			comm_workers[i] = 0
		
		for node in city.land_use:
			var lu: int = city.land_use[node]
			var workers: int = Constants.LU_WORKERS[lu]
			var comm: String = Constants.LU_OUTPUT[lu]
			var comm_id: int = comm_map[comm]
			comm_workers[comm_id] += workers
			total_workers += workers
		
		var target_workers = []
		var max_diff = 0
		var max_index = -1
		target_workers.resize(Constants.COMM_ALL.size())
		for i in range(target_workers.size()):
			target_workers[i] = total_workers * rel_weights[i]
			var diff = target_workers[i] - comm_workers[i]
			if diff > max_diff:
				max_diff = diff
				max_index = i
		
		if max_index < 0:
			return
		
		var max_amount_dist = [0, 9999]
		var max_solution = [-1, -1]
		
		for node in city.cells:
			if not builder.can_set_land_use(city, node):
				continue
			
			var veg = planet_data.get_node(node).vegetation_type
			var lu_options = constants.VEG_MAPPING[veg]
			
			for lu in lu_options:
				if comm_map[Constants.LU_OUTPUT[lu]] == max_index \
						and Constants.LU_WORKERS[lu] <= city.workers:
					var opt: Constants.VegLandUse = lu_options[lu]
					var amount = opt.source.amount if opt.source != null else 0
					
					var dist = city.cells[node]
					if amount > max_amount_dist[0] \
							or (amount == max_amount_dist[0] and dist < max_amount_dist[1]):
						max_amount_dist = [amount, dist]
						max_solution = [node, lu]
			
		if max_solution[0] < 0:
			break
		if not builder.set_land_use(city, max_solution[0], max_solution[1]):
			print("Warning: unable to auto-assign land use")
			break
	


func sum(arr):
	var s = 0
	for v in arr:
		s += v
	return s
