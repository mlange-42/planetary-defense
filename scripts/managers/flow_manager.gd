class_name FlowManager

var MultiCommodityFlow = preload("res://native/multi_commodity.gdns")


var source_cost: int = 0
var sink_cost: int = 0
var load_depencence: float = 0.25


var network: RoadNetwork
var flow = MultiCommodityFlow.new()

func _init(net: RoadNetwork):
	self.network = net

func solve():
	flow.reset()
	
	var edges = network.get_edges()
	var facilities = network.facilities
	
	for edge in edges:
		var p1 = edge[0]
		var p2 = edge[edge.size()-1]
		var cost = edge.size()-1
		var capacity = 10
		flow.add_edge(p1, p2, capacity, cost)
		
	for fid in facilities:
		var facility = facilities[fid]
		for from_to_comm in facility.conversions:
			var from = from_to_comm[0]
			var to = from_to_comm[1]
			var conv = from_to_comm
			if facility.sinks.has(from):
				flow.add_source_edge(facility.node_id, to, 0, source_cost)
				flow.set_converter(facility.node_id, from, conv[0], to, conv[1])
		
		for source in facility.sources:
			print("Adding source %d to %s" % [facility.sources[source], facility.node_id])
			flow.add_source_edge(facility.node_id, source, facility.sources[source], source_cost)
			
		for sink in facility.sinks:
			print("Adding sink %d to %s" % [facility.sinks[sink], facility.node_id])
			flow.add_sink_edge(facility.node_id, sink, facility.sinks[sink], sink_cost)
	
	var result = flow.solve(load_depencence)
	print(result)
