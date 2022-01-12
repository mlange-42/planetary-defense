class_name TaxManager

var budget: int = Consts.INITIAL_BUDGET
var taxes: int = 0
var maintenance: int = 0
var maintenance_roads: int = 0
var maintenance_transport: int = 0
var maintenance_facilities: int = 0
var maintenance_land_use: int = 0


func earn_taxes(total_flows: Dictionary):
	var total = 0
	for comm in total_flows:
		total += Commodities.COMM_TAX_RATES[comm] * total_flows[comm]
	
	taxes = total
	budget += total


func pay_costs(facilities: Dictionary, network):
	maintenance_facilities = 0
	maintenance_land_use = 0
	for node in facilities:
		var fac = facilities[node]
		var type = fac.type
		
		if fac.type == Facilities.FAC_CITY:
			var city: City = fac as City
			maintenance_facilities += Cities.city_maintenance(city.radius)
			for n in city.land_use:
				var lu = city.land_use[n]
				maintenance_land_use += LandUse.LU_MAINTENANCE[lu]
		else:
			maintenance_facilities += Facilities.FACILITY_MAINTENANCE[type]
	
	# warning-ignore:integer_division
	maintenance_roads = int(ceil((network.get_edge_count() / 2) * Network.TYPE_MAINTENANCE_1000[Network.T_ROAD] / 1000.0))
	
	maintenance_transport = int(ceil(network.get_total_flow() * Consts.TRANSPORT_COST_1000 / 1000.0))
	
	maintenance = maintenance_roads + maintenance_transport + maintenance_facilities + maintenance_land_use
	budget -= maintenance


func save() -> Dictionary:
	return {
		"budget": budget,
		"taxes": taxes,
		"maintenance": maintenance,
		"maintenance_facilities": maintenance_facilities,
		"maintenance_land_use": maintenance_land_use,
		"maintenance_roads": maintenance_roads,
		"maintenance_transport": maintenance_transport,
	}


func read(dict: Dictionary):
	budget = dict["budget"] as int
	taxes = dict["taxes"] as int
	maintenance = dict["maintenance"] as int
	maintenance_facilities = dict.get("maintenance_facilities", 0) as int
	maintenance_land_use = dict.get("maintenance_land_use", 0) as int
	maintenance_roads = dict["maintenance_roads"] as int
	maintenance_transport = dict["maintenance_transport"] as int
