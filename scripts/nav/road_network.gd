class_name RoadNetwork

var neighbors: Dictionary = {}
var facilities: Dictionary = {}

func _init():
	pass


func connect_points(v1: int, v2: int):
	_connect(v1, v2)
	_connect(v2, v1)


func disconnect_points(v1: int, v2: int):
	_disconnect(v1, v2)
	_disconnect(v2, v1)


func add_facility(v: int):
	assert(not facilities.has(v), "There is already a facility at node %s" % v)
	facilities[v] = true


func remove_facility(v: int):
	assert(facilities.erase(v), "There is no a facility at node %s to remove" % v)


func points_connected(v1: int, v2: int) -> bool:
	if not neighbors.has(v1):
		return false
	
	var n: Array = neighbors[v1]
	return n.has(v2)


func get_edges():
	var edges = []
	
	for key in neighbors:
		var n: Array = neighbors[key]
		if n.size() == 2 and not facilities.has(key):
			continue
		
		for i in range(n.size()):
			var trace = _trace_edge(key, i)
			if not trace.empty():
				edges.append(trace)
	
	return edges


func _trace_edge(node: int, neighbor: int) -> Array:
	var n: Array
	var result = [node]
	var first = node
	var previous: int = node
	var current: int = neighbors[node][neighbor]
	
	while true:
		if current == first: # dead-end loop -> omit
			return []
		
		result.append(current)
		
		n = neighbors[current]
		if n.size() != 2 or facilities.has(current):
			return result
		
		var n0 = n[0]
		var old = previous
		previous = current
		current = n0 if n0 != old else n[1]
	
	return [] # should never be reached


func _connect(v1: int, v2: int):
	if neighbors.has(v1):
		var n: Array = neighbors[v1]
		assert(not n.has(v2), "Points %d and %d are already connected" % [v1, v2])
		
		n.append(v2)
	else:
		neighbors[v1] = [v2]


func _disconnect(v1: int, v2: int):
	assert(not neighbors.has(v1), "Points %d and %d are not connected" % [v1, v2])
	
	var n: Array = neighbors[v1]
	var idx = n.find(v2)
	assert(idx >= 0, "Points %d and %d are not connected" % [v1, v2])
	
	n.remove(idx)
