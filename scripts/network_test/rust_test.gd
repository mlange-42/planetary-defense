extends Node2D

onready var net = $NetworkSimplex

func _ready():
	_evaluate()

func _evaluate():
	net.reset()
	
	var nodes: Dictionary = {}
	var edges: Dictionary = {}
	var amount: Dictionary = {}
	
	for i in range(net.get_child_count()):
		var ch = net.get_child(i)
		if ch is NetNode:
			ch.id = i
			nodes[i] = ch
			
			if ch.source > 0:
				net.add_source_edge(ch.id, ch.source, 0)
				print("Connected source (%s) to %s" % [ch.source, ch.id])
			if ch.sink > 0:
				net.add_sink_edge(ch.id, ch.sink, 0)
				print("Connected %s to sink (%s)" % [ch.id, ch.sink])
	
	for i in range(net.get_child_count()):
		var ch = net.get_child(i)
		if ch is NetLink:
			var start = ch.get_node(ch.start)
			var end = ch.get_node(ch.end)
			var cost = int(ch.cost * (end.position - start.position).length())
			net.add_edge(start.id, end.id, ch.capacity, cost)
			edges[[start.id, end.id]] = ch
			amount[[start.id, end.id]] = 0
			print("Connected %s -> %s (cap: %s, cost: %s)" % [start.id, end.id, ch.capacity, cost])
	
	var paths = net.solve()
	print(paths)
	
	for path in paths:
		for edge in path:
			var from = edge[0]
			var to = edge[1]
			var amnt = edge[2]
			#var cost = edge[3]
			
			if from >= 0 and to >= 0:
				amount[[from, to]] += amnt
			else:
				if from < 0:
					nodes[to].set_source_amount(amnt)
				if to < 0:
					nodes[from].set_sink_amount(amnt)
	
	for key in edges:
		edges[key].set_amount(amount[key])
