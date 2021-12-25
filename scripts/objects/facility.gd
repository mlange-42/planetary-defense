extends Spatial
class_name Facility

var facility_id: int
var node_id: int

var sources: Dictionary
var sinks: Dictionary
var conversions: Dictionary

var flows: Dictionary

# warning-ignore:unused_argument
func init(node: int, planet_data):
	self.node_id = node

# warning-ignore:unused_argument
func on_ready(planet_data):
	pass

func add_source(commodity: String, amount: int):
	if commodity in sources:
		sources[commodity] += amount
	else:
		sources[commodity] = amount

func add_sink(commodity: String, amount: int):
	if commodity in sinks:
		sinks[commodity] += amount
	else:
		sinks[commodity] = amount

func add_conversion(from: String, from_amount: int, to: String, to_amount: int, max_amount):
	conversions[[from, to]] = [from_amount, to_amount]
	add_sink(from, max_amount)
