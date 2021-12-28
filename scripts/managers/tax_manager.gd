class_name TaxManager

var budget: int = Constants.INITIAL_BUDGET
var taxes: int = 0
var maintenance: int = 0


func reset():
	taxes = 0
	maintenance = 0

func earn_taxes(total_flows: Dictionary):
	var total = 0
	for comm in total_flows:
		total += Constants.COMM_TAX_RATES[comm] * total_flows[comm]
	
	taxes = total
	budget += total

func pay_road_maintenenace(num_edges: int):
	# warning-ignore:integer_division
	maintenance = int(ceil((num_edges / 2) * Constants.ROAD_MAINTENANCE_10 / 10.0))
	budget -= maintenance


func save() -> Dictionary:
	return {
		"budget": budget,
		"taxes": taxes,
		"maintenance": maintenance,
	}


func read(dict: Dictionary):
	budget = dict["budget"] as int
	taxes = dict["taxes"] as int
	maintenance = dict["maintenance"] as int
