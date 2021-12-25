class_name CityManager

var constants: Constants
var network: RoadNetwork
var planet_data = null

# warning-ignore:shadowed_variable
func _init(consts: Constants, net: RoadNetwork, planet_data):
	self.constants = consts
	self.network = net
	self.planet_data = planet_data

func update():
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
		var workers_to_feed = 0
		
		var keys = city.land_use.keys()
		keys.shuffle()
		for node in keys:
			var lu = city.land_use[node]
			var data = planet_data.get_node(node)
			
			print("Processing node %d (LU=%d)" % [node, lu])
			
			var lu_data = constants.LU_MAPPING[lu]
			if not data.vegetation_type in lu_data.vegetations:
				continue
			
			var veg_data: Constants.VegLandUse = lu_data.vegetations[data.vegetation_type]
			
			if veg_data.source == null or veg_data.source.commodity != Constants.COMM_FOOD:
				workers_to_feed += lu_data.workers
				if food_available >= lu_data.workers:
					food_available -= lu_data.workers
				else:
					continue
			
			print(" sum food req = %d" % workers_to_feed)
			print(" sum food rem = %d" % food_available)
			
			if veg_data.source != null:
				city.add_source(veg_data.source.commodity, veg_data.source.amount)
			
			if veg_data.sink != null:
				city.add_sink(veg_data.sink.commodity, veg_data.sink.amount)
		
			if veg_data.conversion != null:
				var c: Constants.Conversion = veg_data.conversion
				city.add_conversion(c.from, c.from_amount, c.to, c.to_amount, c.max_from_amount)
		
		city.add_sink(Constants.COMM_FOOD, workers_to_feed)
