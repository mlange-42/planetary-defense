extends Node2D

export var source_cost: int = 0
export var sink_cost: int = 0
export (float, 0, 5) var load_depencence: float = 0

onready var net = $NetworkSimplex

var total_cost: int
var total_amount: int
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
	
	var all_nodes = net.get_node("Nodes").get_children()
	var all_edges = net.get_node("Links").get_children()
	for i in range(all_nodes.size()):
		var ch = all_nodes[i]
		if ch is NetNode:
			ch.id = i
			nodes[i] = ch
			
			if ch.source > 0:
				net.add_source_edge(ch.id, ch.commodity, ch.source, source_cost)
				source_amount[ch.id] = 0
			if ch.sink > 0:
				net.add_sink_edge(ch.id, ch.commodity, ch.sink, sink_cost)
				sink_amount[ch.id] = 0
	
	for ch in all_edges:
		if ch is NetLink:
			var start = ch.get_node(ch.start)
			var end = ch.get_node(ch.end)
			var cost = int(ch.cost * (end.position - start.position).length())
			net.add_edge(start.id, end.id, ch.capacity, cost)
			edges[[start.id, end.id]] = ch
			edge_amount[[start.id, end.id]] = 0
	
	var flows = net.solve(load_depencence)
	
	print(flows)
	
	total_amount = 0
	
	for edge in flows:
		var from = edge[0]
		var to = edge[1]
		var amnt = edge[2]
		#var cost = edge[3]
		
		if from >= 0 and to >= 0:
			edge_amount[[from, to]] = amnt
		else:
			if from < 0:
				source_amount[to] = amnt
				total_amount += amnt
			if to < 0:
				sink_amount[from] += amnt
	
	for key in edges:
		edges[key].set_amount(edge_amount[key])
		
	for key in source_amount:
		nodes[key].set_source_amount(source_amount[key])
		
	for key in sink_amount:
		nodes[key].set_sink_amount(sink_amount[key])
	
	print("Amount: %d" % [total_amount])


func print_cost_hist(cost_stats):
	var bins = 10
	var width = 50
	
	print("Cost statistics:")
	
	var max_cost = 0
	var max_amount = 0
	
	for entry in cost_stats:
		if entry[0] > max_cost: max_cost = entry[0]
	
	var step = (max_cost * 1.0001) / float(bins)
	var bin_values = []
	for _i in range(bins): bin_values.append(0)
	
	for entry in cost_stats:
		var b = int(entry[0] / step)
		bin_values[b] += entry[1]
	
	for v in bin_values:
		if v > max_amount: max_amount = v
		
	var scale = width / float(max_amount)
	
	for i in range(bins):
		bin_values[i] = round(bin_values[i] * scale)
	
	for i in range(bins-1, -1, -1):
		var v = bin_values[i]
		var prefix = ("%6d |" % max_cost) if i == bins-1 else "      0|" if i == 0 else "       |"
		var s = ""
		for _j in range(v): s += "#"
		
		if i == 0: 
			for _j in range(width - s.length()):
				s += " "
			s += " " + str(max_amount)
		print(prefix + s)
	
