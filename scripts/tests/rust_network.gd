extends Spatial

var net = null

func _ready():
	var tp = 0
	var cap = 25
	
	net = FlowNetwork.new()
	
	net.connect_points(2, 3, tp, cap)
	net.connect_points(1, 2, tp, cap)
	net.connect_points(0, 1, tp, cap)
	
	net.connect_points(2, 4, tp, cap)


func _input(event: InputEvent):
	if event.is_pressed():
		print(net.points_connected(0, 1))
		print(net.is_road(2))
		
		for i in range(net.get_node_count()):
			print(net.get_node_at(i))
		
		for i in range(net.get_edge_count()):
			var edge = net.get_edge_at(i)
			print(edge)
			print(edge[2].capacity)
