class_name RoadNetwork

const MAX_INT = 9223372036854775807

class Edge:
	var from: int
	var to: int
	var flow: int
	var capacity: int
	
	func _init(from_id: int, to_id: int, cap: int):
		self.from = from_id
		self.to = to_id
		self.capacity = cap

var _neighbors: Dictionary = {}
var _edges: Dictionary = {}
var _facilities: Dictionary = {}

var total_flows: Dictionary = {}
var pair_flows: Dictionary = {}
var total_sources: Dictionary = {}
var total_sinks: Dictionary = {}

func _init():
	pass


func save() -> Dictionary:
	var dict = {}
	
	var neigh = []
	for n in _neighbors:
		neigh.append([n, _neighbors[n]])
	
	dict["neighbors"] = neigh
	
	var edge_data = []
	for edge in _edges:
		var e = _edges[edge]
		edge_data.append([edge[0], edge[1], e.capacity, e.flow])
	
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
	var neigh = dict["neighbors"]
	self._neighbors = {}
	for n in neigh:
		var nn = n[1]
		var arr = []
		for node in nn:
			arr.append(node as int)
		
		self._neighbors[n[0] as int] = arr
	
	var capacity = dict["edge_data"]
	for edge in capacity:
		var v1 = edge[0] as int
		var v2 = edge[1] as int
		var cap = edge[2] as int
		var fl = edge[3] as int
		
		var e = Edge.new(v1, v2, cap)
		e.flow = fl
		_edges[[v1, v2]] = e
	
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


func connect_points(v1: int, v2: int, capacity: int):
	_connect(v1, v2, capacity)
	_connect(v2, v1, capacity)


func disconnect_points(v1: int, v2: int):
	_disconnect(v1, v2)
	_disconnect(v2, v1)


func neighbors() -> Dictionary:
	return _neighbors


func facilities() -> Dictionary:
	return _facilities


func add_facility(v: int, facility: Facility):
	assert(not _facilities.has(v), "There is already a facility at node %s" % v)
	_facilities[v] = facility


func remove_facility(v: int):
	assert(_facilities.erase(v), "There is no a facility at node %s to remove" % v)


func has_facility(v: int) -> bool:
	return _facilities.has(v)


func is_road(v: int) -> bool:
	return _neighbors.has(v)


func get_facility(v: int) -> Facility:
	return _facilities.get(v)


func points_connected(v1: int, v2: int) -> bool:
	return _edges.has([v1, v2])


func edges() -> Dictionary:
	return _edges


func get_edge(key: Array) -> Edge:
	return _edges.get(key)


func get_collapsed_edges() -> Array:
	var edge_list = []
	
	for key in _neighbors:
		var n: Array = _neighbors[key]
		if n.size() == 2 and not _facilities.has(key):
			continue
		
		for i in range(n.size()):
			var trace = _trace_edge(key, i)
			if not trace.empty():
				edge_list.append(trace)
	
	return edge_list


func reset_flow():
	for edge in _edges.values():
		edge.flow = 0
	
	for comm in Commodities.COMM_ALL:
		total_flows[comm] = 0


func _trace_edge(node: int, neighbor: int) -> Array:
	var n: Array
	var result = [node]
	var first = node
	var previous: int = node
	var current: int = _neighbors[node][neighbor]
	var capacity = MAX_INT
	
	while true:
		if current == first: # dead-end loop -> omit
			return []
		
		result.append(current)
		var edge: Edge = _edges[[previous, current]]
		if edge.capacity < capacity:
			capacity = edge.capacity
		
		n = _neighbors[current]
		if n.size() != 2 or _facilities.has(current):
			return [result, capacity]
		
		var n0 = n[0]
		var old = previous
		previous = current
		current = n0 if n0 != old else n[1]
	
	return [] # should never be reached


func _connect(v1: int, v2: int, capacity: int):
	if _neighbors.has(v1):
		var n: Array = _neighbors[v1]
		assert(not n.has(v2), "Points %d and %d are already connected" % [v1, v2])
		
		n.append(v2)
	else:
		_neighbors[v1] = [v2]
	
	_edges[[v1, v2]] = Edge.new(v1, v2, capacity)


func _disconnect(v1: int, v2: int):
	assert(_neighbors.has(v1), "Points %d and %d are not connected" % [v1, v2])
	
	var n: Array = _neighbors[v1]
	var idx = n.find(v2)
	assert(idx >= 0, "Points %d and %d are not connected" % [v1, v2])
	
	n.remove(idx)
	assert(_edges.erase([v1, v2]), "Points %d and %d have no edge to remove" % [v1, v2])
	
	if n.empty():
		assert(_neighbors.erase(v1), "Points %d and %d are not connected" % [v1, v2])
