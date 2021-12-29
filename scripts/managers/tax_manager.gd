class_name TaxManager

var budget: int = Constants.INITIAL_BUDGET
var taxes: int = 0
var maintenance: int = 0
var maintenance_roads: int = 0
var maintenance_transport: int = 0


func earn_taxes(total_flows: Dictionary):
	var total = 0
	for comm in total_flows:
		total += Constants.COMM_TAX_RATES[comm] * total_flows[comm]
	
	taxes = total
	budget += total


func road_transport_costs(edges: Dictionary):
	# warning-ignore:integer_division
	maintenance_roads = int(ceil((edges.size() / 2) * Constants.ROAD_MAINTENANCE_1000 / 1000.0))
	
	var total = 0
	for nn in edges:
		total += edges[nn].flow
	
	maintenance_transport = int(ceil(total * Constants.TRANSPORT_COST_1000 / 1000.0))
	
	maintenance = maintenance_roads + maintenance_transport
	budget -= maintenance


func save() -> Dictionary:
	return {
		"budget": budget,
		"taxes": taxes,
		"maintenance": maintenance,
		"maintenance_roads": maintenance_roads,
		"maintenance_transport": maintenance_transport,
	}


func read(dict: Dictionary):
	budget = dict["budget"] as int
	taxes = dict["taxes"] as int
	maintenance = dict["maintenance"] as int
	maintenance_roads = dict["maintenance_roads"] as int
	maintenance_transport = dict["maintenance_transport"] as int
