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
			if not data.vegetation_type in lu_data.vegetations:
				continue
			
			products_required += lu_data.workers
			
			var veg_data: Constants.VegLandUse = lu_data.vegetations[data.vegetation_type]
			if veg_data.source == null or veg_data.source.commodity != Constants.COMM_FOOD:
				workers_to_feed += lu_data.workers
				if food_available >= lu_data.workers:
					food_available -= lu_data.workers
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
		
		var products_required = city.workers
		
		var all_workers_supplied = food_available >= 0
		
		for node in city.land_use:
			var lu = city.land_use[node]
			var data = planet_data.get_node(node)
			
			var lu_data = constants.LU_MAPPING[lu]
			if not data.vegetation_type in lu_data.vegetations:
				continue
			
			products_required += lu_data.workers
			
			var veg_data: Constants.VegLandUse = lu_data.vegetations[data.vegetation_type]
			if veg_data.source == null or veg_data.source.commodity != Constants.COMM_FOOD:
				if food_available >= lu_data.workers:
					food_available -= lu_data.workers
				else:
					all_workers_supplied = false
					break
		
		var products_available = city.flows[Constants.COMM_PRODUCTS][1] if Constants.COMM_PRODUCTS in city.flows else 0
		var share_satisfied = clamp(products_available / float(products_required / 2), 0, 1)
		
		if all_workers_supplied:
			print("%s: food satified, products %d%%" % [city.name, round(share_satisfied*100)])
			if randf() < Constants.CITY_GROWTH_PROB * share_satisfied:
				city.workers += 1
				city.update_visuals(planet_data)
