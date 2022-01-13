class_name FlowManager

var MultiCommodityFlow = preload("res://scripts/native/multi_commodity.gdns")


var source_cost: int = 25
var sink_cost: int = 25
var load_depencence: float = 0.25
var bidirectional: bool = false

var network: NetworkManager
var flow = MultiCommodityFlow.new()

func _init(net: NetworkManager):
	self.network = net


func clear():
	network.reset_flow()

func solve():
	flow.reset()
	
	var facilities = network.facilities()
	
	var edges = network.network.get_collapsed_edges()
	flow.add_edges(edges)
	
	for fid in facilities:
		var facility = facilities[fid]
		for from_to_comm in facility.conversions:
			var from = from_to_comm[0]
			var to = from_to_comm[1]
			var conv = facility.conversions[from_to_comm]
			
			if facility.sinks.has(from):
				flow.add_source_edge(Commodities.to_mode_id(facility.node_id, to), to, 0, source_cost)
				flow.set_converter(Commodities.to_mode_id(facility.node_id, from), \
									from, conv[0], to, conv[1],\
									Commodities.to_mode_id(facility.node_id, to))
		
		for source in facility.sources:
			flow.add_source_edge(Commodities.to_mode_id(facility.node_id, source), source, facility.sources[source], source_cost)
			
		for sink in facility.sinks:
			flow.add_sink_edge(Commodities.to_mode_id(facility.node_id, sink), sink, facility.sinks[sink], sink_cost)
	
	flow.solve(bidirectional, load_depencence)
	
	for fid in facilities:
		facilities[fid].clear_flows()
		for mode in Network.ALL_MODES:
			var mode_id = Network.to_mode_id(fid, mode)
			var f = flow.get_node_flows(mode_id)
			if f != null:
				facilities[fid].add_flows(f)
	
	self.clear()
	
	var flows = flow.get_flows()
	var i = 0
	for edge in flows:
		# TODO: check - was < 1 before, not sure why. < 0 should be sink or source
		if edge[0] < 0 or edge[1] < 0: # or edge[0] == edge[1]:
			continue
		
		var path_cap = edges[i]
		var path = path_cap[0]
		var amount = edge[2]
		
		for j in range(path.size()-1):
			network.network.set_edge_flow(path[j], path[j+1], amount)
		
		i += 1
	
	var total_flows: Dictionary = {}
	for comm in Commodities.COMM_ALL:
		total_flows[comm] = 0
	
	var pair_flows = flow.get_pair_flows()
	var res_pair_flows = {}
	for edge in pair_flows:
		var edge_flow = pair_flows[edge]
		res_pair_flows[[Network.to_base_id(edge[0]), Network.to_base_id(edge[1])]] = edge_flow
		for comm in edge_flow:
			total_flows[comm] += edge_flow[comm]
	
	
	network.pair_flows = res_pair_flows
	network.total_flows = total_flows
	network.total_sources = flow.get_total_sources()
	network.total_sinks = flow.get_total_sinks()
	
