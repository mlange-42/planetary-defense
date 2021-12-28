class_name TaxManager

var budget: int = 100
var taxes: int = 0
var maintenance: int = 0

func earn_taxes(total_flows: Dictionary):
	var total = 0
	for comm in total_flows:
		total += Constants.COMM_TAX_RATES[comm] * total_flows[comm]
	
	taxes = total
	budget += total
