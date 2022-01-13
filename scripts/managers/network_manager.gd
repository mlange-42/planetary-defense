class_name NetworkManager

const MAX_INT = 9223372036854775807

var network = FlowNetwork.new()
var _facilities: Dictionary = {}

var total_flows: Dictionary = {}
var pair_flows: Dictionary = {}
var total_sources: Dictionary = {}
var total_sinks: Dictionary = {}

func _init():
	pass


func save() -> Dictionary:
	var dict = {}
	
	var edge_data = []
	for i in range(network.get_edge_count()):
		var e = network.get_edge_at(i)
		if Network.get_mode(e.from) == Network.get_mode(e.to):
			edge_data.append([e.from, e.to, e.net_type, e.capacity, e.flow])
	
	dict["edge_data"] = edge_data
	
	var pair_data = []
	for edge in pair_flows:
		var flows = pair_flows[edge]
		var entry = []
		for comm in flows:
			entry.append([comm, flows[comm]])
		pair_data.append([edge, entry])
	
	dict["pair_flows"] = pair_data
	dict["total_flows"] = total_flows
	dict["total_sources"] = total_sources
	dict["total_sinks"] = total_sinks
	
	return dict


func read(dict: Dictionary):
	var capacity = dict["edge_data"]
	for edge in capacity:
		var v1 = edge[0] as int
		var v2 = edge[1] as int
		var tp = edge[2] as int
		var cap = edge[3] as int
		var fl = edge[4] as int
		
		network.connect_points_directional(v1, v2, tp, cap, fl)
	
	var p_flows = dict["pair_flows"]
	for e in p_flows:
		var edge = e[0]
		var flows = e[1]
		var edge_dict = {}
		for comm in flows:
			edge_dict[comm[0]] = comm[1] as int
		
		pair_flows[[edge[0] as int, edge[1] as int]] = edge_dict
	
	var t_flows = dict["total_flows"]
	for comm in t_flows:
		total_flows[comm] = t_flows[comm] as int
		
	var t_sources = dict["total_sources"]
	for comm in t_sources:
		total_sources[comm] = t_sources[comm] as int
		
	var t_sinks = dict["total_sinks"]
	for comm in t_sinks:
		total_sinks[comm] = t_sinks[comm] as int


func connect_points(v1: int, v2: int, type: int, capacity: int):
	network.connect_points(v1, v2, type, capacity)


func disconnect_points(v1: int, v2: int):
	network.disconnect_points(v1, v2)


func facilities() -> Dictionary:
	return _facilities


func add_facility(v: int, facility: Facility):
	assert(not _facilities.has(v), "There is already a facility at node %s" % v)
	_facilities[v] = facility
	for mode in Facilities.FACILITY_NETWORK_MODES[facility.type]:
		network.set_facility(Network.to_mode_id(v, mode), true)


func remove_facility(v: int):
	var fac = _facilities.get(v)
	assert(_facilities.erase(v), "There is no a facility at node %s to remove" % v)
	for mode in Facilities.FACILITY_NETWORK_MODES[fac.type]:
		network.set_facility(Network.to_mode_id(v, mode), false)


func has_facility(v: int) -> bool:
	return _facilities.has(v)


func is_road(v: int) -> bool:
	return network.is_road(v)


func get_facility(v: int) -> Facility:
	return _facilities.get(v)


func points_connected(v1: int, v2: int) -> bool:
	return network.points_connected(v1, v2)


func get_id_path(v1: int, v2: int):
	return network.get_id_path(v1, v2)


func path_exists(v1: int, v2: int):
	if network.is_road(v1) and network.is_road(v1):
		var path = network.get_id_path(v1, v2)
		if not path.empty():
			return true
	return false


func get_edge(key: Array):
	return network.get_edge(key)


func reset_flow():
	network.reset_flow()
	
	for comm in Commodities.COMM_ALL:
		total_flows[comm] = 0
