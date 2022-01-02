class_name TaxManager

var budget: int = Consts.INITIAL_BUDGET
var taxes: int = 0
var maintenance: int = 0
var maintenance_roads: int = 0
var maintenance_transport: int = 0
var maintenance_facilities: int = 0


func earn_taxes(total_flows: Dictionary):
	var total = 0
	for comm in total_flows:
		total += Commodities.COMM_TAX_RATES[comm] * total_flows[comm]
	
	taxes = total
	budget += total


func pay_costs(facilities: Dictionary, network_edges: Dictionary):
	maintenance_facilities = 0
	for node in facilities:
		var type = facilities[node].type
		maintenance_facilities += Facilities.FACILITY_MAINTENANCE[type]
	
	# warning-ignore:integer_division
	maintenance_roads = int(ceil((network_edges.size() / 2) * Consts.ROAD_MAINTENANCE_1000 / 1000.0))
	
	var total = 0
	for nn in network_edges:
		total += network_edges[nn].flow
	
	maintenance_transport = int(ceil(total * Consts.TRANSPORT_COST_1000 / 1000.0))
	
	maintenance = maintenance_roads + maintenance_transport + maintenance_facilities
	budget -= maintenance


func save() -> Dictionary:
	return {
		"budget": budget,
		"taxes": taxes,
		"maintenance": maintenance,
		"maintenance_facilities": maintenance_facilities,
		"maintenance_roads": maintenance_roads,
		"maintenance_transport": maintenance_transport,
	}


func read(dict: Dictionary):
	budget = dict["budget"] as int
	taxes = dict["taxes"] as int
	maintenance = dict["maintenance"] as int
	maintenance_facilities = dict.get("maintenance_facilities", 0) as int
	maintenance_roads = dict["maintenance_roads"] as int
	maintenance_transport = dict["maintenance_transport"] as int
