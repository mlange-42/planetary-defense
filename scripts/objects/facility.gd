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

var is_supplied: bool = false


# warning-ignore:shadowed_variable
# warning-ignore:unused_argument
func init(node: int, planet_data, type: String):
	self.node_id = node
	self.type = type
	
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
	pass


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
	for comm in fl:
		var f = fl[comm]
		flows[comm] = [f[0] as int, f[1] as int]
		
	var so = dict["sources"]
	for comm in so:
		sources[comm] = so[comm] as int
		
	var si = dict["sinks"]
	for comm in si:
		sinks[comm] = si[comm] as int
		
	var co = dict["conversions"]
	for comm in co:
		var c = comm[1]
		conversions[comm[0]] = [c[0] as int, c[1] as int]


func calc_is_supplied():
	var res = true
	for comm in sinks:
		var flow = flows.get(comm, [0, 0])
		if flow[1] < sinks[comm]:
			res = false
			break
	
	is_supplied = res


func get_missing_supply() -> Dictionary:
	var res = {}
	
	for comm in sinks:
		var flow = flows.get(comm, [0, 0])
		if flow[1] < sinks[comm]:
			res[comm] = res.get(comm, 0) + sinks[comm] - flow[1]
	
	return res


func clear_flows():
	flows.clear()

func add_flows(f: Dictionary):
	for key in f:
		var v = f[key]
		if flows.has(key):
			var old = flows[key]
			flows[key] = [old[0] + v[0], old[1] + v[1]]
		else:
			flows[key] = v

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
