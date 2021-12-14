extends Node2D

onready var net = $NetworkSimplex

var paths: Array
var nodes: Dictionary
var edges: Dictionary
var edge_amount: Dictionary
var source_amount: Dictionary
var sink_amount: Dictionary

func _ready():
	_evaluate()

func _evaluate():
	net.reset()
	
	nodes = {}
	edges = {}
	edge_amount = {}
	source_amount = {}
	sink_amount = {}
	
	for i in range(net.get_child_count()):
		var ch = net.get_child(i)
		if ch is NetNode:
			ch.id = i
			nodes[i] = ch
			
			if ch.source > 0:
				net.add_source_edge(ch.id, ch.source, 0)
				source_amount[ch.id] = 0
				print("Connected source (%s) to %s" % [ch.source, ch.id])
			if ch.sink > 0:
				net.add_sink_edge(ch.id, ch.sink, 0)
				sink_amount[ch.id] = 0
				print("Connected %s to sink (%s)" % [ch.id, ch.sink])
	
	for i in range(net.get_child_count()):
		var ch = net.get_child(i)
		if ch is NetLink:
			var start = ch.get_node(ch.start)
			var end = ch.get_node(ch.end)
			var cost = int(ch.cost * (end.position - start.position).length())
			net.add_edge(start.id, end.id, ch.capacity, cost)
			edges[[start.id, end.id]] = ch
			edge_amount[[start.id, end.id]] = 0
			print("Connected %s -> %s (cap: %s, cost: %s)" % [start.id, end.id, ch.capacity, cost])
	
	paths = net.solve()
	print(paths)
	
	for path in paths:
		for edge in path:
			var from = edge[0]
			var to = edge[1]
			var amnt = edge[2]
			#var cost = edge[3]
			
			if from >= 0 and to >= 0:
				edge_amount[[from, to]] += amnt
			else:
				if from < 0:
					source_amount[to] += amnt
				if to < 0:
					sink_amount[from] += amnt
	
	for key in edges:
		edges[key].set_amount(edge_amount[key])
		
	for key in source_amount:
		nodes[key].set_source_amount(source_amount[key])
		
	for key in sink_amount:
		nodes[key].set_sink_amount(sink_amount[key])

func _unhandled_input(event):
	pass
