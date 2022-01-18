extends Spatial
class_name Facility

var city_node_id: int = -1

var type: String

var facility_id: int
var node_id: int

# key: comm id, value: amount
var sources: Array = Commodities.create_int_array()
# key: comm id, value: amount
var sinks: Array = Commodities.create_int_array()
# key: [from comm, to comm], value: [from amount, to amount, max from amount]
var conversions: Dictionary

# key comm id, values: amounts [sent, received]
var flows: Array

var is_supplied: bool = false


# warning-ignore:shadowed_variable
# warning-ignore:unused_argument
func init(node: int, planet, type: String):
	self.node_id = node
	self.type = type
	
	flows = []
	for _c in Commodities.COMM_ALL:
		flows.append([0, 0])
	
	var s = Facilities.FACILITY_SINKS[type]
	if s != null:
		for sink in s:
			add_sink(sink[0], sink[1])
			
	s = Facilities.FACILITY_SOURCES[type]
	if s != null:
		for source in s:
			add_source(source[0], source[1])

	s = Facilities.FACILITY_CONVERSIONS[type]
	if s != null:
		for conv in s:
			add_conversion(conv[0], conv[1], conv[2], conv[3], conv[4])


# warning-ignore:unused_argument
func on_ready(_planet_data):
	calc_is_supplied()


func removed(_planet):
	pass


func save() -> Dictionary:
	var conv = []
	for key in conversions:
		var c = conversions[key]
		conv.append([key, c])
	
	var dict = {
		"type": type,
		"name": name,
		"node_id": node_id,
		"city_node_id": city_node_id,
		"sources": sources,
		"sinks": sinks,
		"conversions": conv,
		"flows": flows,
		"is_supplied": is_supplied,
	}
	return dict


func read(dict: Dictionary):
	name = dict["name"]
	node_id = dict["node_id"] as int
	city_node_id = dict["city_node_id"] as int
	is_supplied = dict["is_supplied"] as bool
	
	var fl = dict["flows"]
	for i in range(flows.size()):
		var f = fl[i]
		flows[i] = [f[0] as int, f[1] as int]
		
	var so = dict["sources"]
	for i in range(so.size()):
		sources[i] = so[i] as int
		
	var si = dict["sinks"]
	for i in range(si.size()):
		sinks[i] = si[i] as int
		
	var co = dict["conversions"]
	for comm in co:
		var c = comm[1]
		conversions[comm[0] as int] = [c[0] as int, c[1] as int, c[2]]


func calc_is_supplied():
	var res = true
	for comm in range(sinks.size()):
		var flow = flows[comm]
		if flow[1] < sinks[comm]:
			res = false
			break
	
	is_supplied = res


func get_missing_supply() -> Dictionary:
	var res = Commodities.create_int_array()
	
	for comm in range(sinks.size()):
		var flow = flows[comm]
		if flow[1] < sinks[comm]:
			res[comm] += sinks[comm] - flow[1]
	
	return res


func get_total_sources() -> Array:
	var res = Commodities.create_int_array()
	for i in range(sources.size()):
		res[i] += sources[i]
	
	for c in conversions:
		var to = c[1]
		var amount = conversions[c]
		var out_value = (amount[2] * amount[1]) / amount[0]
		res[to] += out_value
	
	return res


func clear_flows():
	for i in range(flows.size()):
		flows[i][0] = 0
		flows[i][1] = 0

func clear_production():
	for i in range(sources.size()):
		sources[i] = 0
		sinks[i] = 0
	conversions.clear()

# TODO: make argument an array
func add_flows(f: Dictionary):
	for key in f:
		var v = f[key]
		var old = flows[key]
		flows[key] = [old[0] + v[0], old[1] + v[1]]

func add_source(commodity: int, amount: int):
	sources[commodity] += amount

func add_sink(commodity: int, amount: int):
	sinks[commodity] += amount

func add_conversion(from: int, from_amount: int, to: int, to_amount: int, max_amount):
	conversions[[from, to]] = [from_amount, to_amount, max_amount]
	add_sink(from, max_amount)
