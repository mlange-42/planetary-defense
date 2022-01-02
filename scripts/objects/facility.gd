extends Spatial
class_name Facility

var city_node_id: int = -1

var type: String

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


func save() -> Dictionary:
	var dict = {
		"type": type,
		"name": name,
		"node_id": node_id,
		"city_node_id": city_node_id,
	}
	return dict


func read(dict: Dictionary):
	name = dict["name"]
	node_id = dict["node_id"] as int
	city_node_id = dict["city_node_id"] as int


# warning-ignore:unused_argument
# warning-ignore:unused_argument
func can_build(planet_data, node) -> bool:
	return false

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
