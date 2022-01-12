extends Spatial

var net = null

func _ready():
	net = FlowNetwork.new()
	
	net.connect_points(0, 1, 25)
	net.connect_points(1, 2, 25)
	net.connect_points(2, 3, 25)
	
	net.connect_points(2, 4, 25)


func _input(event: InputEvent):
	if event.is_pressed():
		print(net.points_connected(0, 1))
		print(net.is_road(2))
