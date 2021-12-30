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

var neighbors: Dictionary = {}
var edges: Dictionary = {}
var facilities: Dictionary = {}

var total_flows: Dictionary = {}
var pair_flows: Dictionary = {}
var total_sources: Dictionary = {}
var total_sinks: Dictionary = {}

func _init():
	pass


func save() -> Dictionary:
	var dict = {}
	
	var neigh = []
	for n in neighbors:
		neigh.append([n, neighbors[n]])
	
	dict["neighbors"] = neigh
	
	var edge_data = []
	for edge in edges:
		var e = edges[edge]
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
	self.neighbors = {}
	for n in neigh:
		var nn = n[1]
		var arr = []
		for node in nn:
			arr.append(node as int)
		
		self.neighbors[n[0] as int] = arr
	
	var capacity = dict["edge_data"]
	for edge in capacity:
		var v1 = edge[0] as int
		var v2 = edge[1] as int
		var cap = edge[2] as int
		var fl = edge[3] as int
		
		var e = Edge.new(v1, v2, cap)
		e.flow = fl
		edges[[v1, v2]] = e
	
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


func add_facility(v: int, facility: Facility):
	assert(not facilities.has(v), "There is already a facility at node %s" % v)
	facilities[v] = facility


func remove_facility(v: int):
	assert(facilities.erase(v), "There is no a facility at node %s to remove" % v)


func has_facility(v: int) -> bool:
	return facilities.has(v)


func is_road(v: int) -> bool:
	return neighbors.has(v)


func get_facility(v: int):
	if not facilities.has(v):
		return null
	return facilities[v]


func points_connected(v1: int, v2: int) -> bool:
	return edges.has([v1, v2])


func get_edges():
	var edge_list = []
	
	for key in neighbors:
		var n: Array = neighbors[key]
		if n.size() == 2 and not facilities.has(key):
			continue
		
		for i in range(n.size()):
			var trace = _trace_edge(key, i)
			if not trace.empty():
				edge_list.append(trace)
	
	return edge_list


func reset_flow():
	for edge in edges.values():
		edge.flow = 0
	
	for comm in Constants.COMM_ALL:
		total_flows[comm] = 0


func _trace_edge(node: int, neighbor: int) -> Array:
	var n: Array
	var result = [node]
	var first = node
	var previous: int = node
	var current: int = neighbors[node][neighbor]
	var capacity = MAX_INT
	
	while true:
		if current == first: # dead-end loop -> omit
			return []
		
		result.append(current)
		var edge: Edge = edges[[previous, current]]
		if edge.capacity < capacity:
			capacity = edge.capacity
		
		n = neighbors[current]
		if n.size() != 2 or facilities.has(current):
			return [result, capacity]
		
		var n0 = n[0]
		var old = previous
		previous = current
		current = n0 if n0 != old else n[1]
	
	return [] # should never be reached


func _connect(v1: int, v2: int, capacity: int):
	if neighbors.has(v1):
		var n: Array = neighbors[v1]
		assert(not n.has(v2), "Points %d and %d are already connected" % [v1, v2])
		
		n.append(v2)
	else:
		neighbors[v1] = [v2]
	
	edges[[v1, v2]] = Edge.new(v1, v2, capacity)


func _disconnect(v1: int, v2: int):
	assert(neighbors.has(v1), "Points %d and %d are not connected" % [v1, v2])
	
	var n: Array = neighbors[v1]
	var idx = n.find(v2)
	assert(idx >= 0, "Points %d and %d are not connected" % [v1, v2])
	
	n.remove(idx)
	assert(edges.erase([v1, v2]), "Points %d and %d have no edge to remove" % [v1, v2])
	
	if n.empty():
		assert(neighbors.erase(v1), "Points %d and %d are not connected" % [v1, v2])