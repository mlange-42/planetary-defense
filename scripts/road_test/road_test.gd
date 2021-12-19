extends Spatial


func _ready():
	var net = RoadNetwork.new()
	
	net.connect_points(0, 1)
	net.connect_points(1, 2)
	net.connect_points(2, 3)
	net.connect_points(3, 4)
	
	net.add_facility(2)
	
	print(net.get_edges())
