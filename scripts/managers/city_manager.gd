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
		
		for node in city.land_use:
			var lu = city.land_use[node]
			var data = planet_data.get_node(node)
			
			var lu_data = constants.LU_MAPPING[lu]
			
			if not data.vegetation_type in lu_data.vegetations:
				continue
			
			var veg_data = lu_data.vegetations[data.vegetation_type]
			
			if veg_data.source != null:
				if veg_data.source.commodity in city.sources:
					city.sources[veg_data.source.commodity] += veg_data.source.amount
				else:
					city.sources[veg_data.source.commodity] = veg_data.source.amount
			
			if veg_data.sink != null:
				if veg_data.sink.commodity in city.sinks:
					city.sinks[veg_data.sink.commodity] += veg_data.sink.amount
				else:
					city.sinks[veg_data.sink.commodity] = veg_data.sink.amount
		
			if veg_data.conversion != null:
				if veg_data.conversion.from in city.sinks:
					city.sinks[veg_data.conversion.from] += veg_data.conversion.max_to_amount
				else:
					city.sinks[veg_data.conversion.from] = veg_data.conversion.max_to_amount
				
				var key = [veg_data.conversion.from, veg_data.conversion.to]
				city.conversions[key] = [veg_data.conversion.from_amount, veg_data.conversion.to_amount]
		
