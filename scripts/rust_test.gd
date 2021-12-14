extends Node2D

onready var rusty = $Node

func _ready():
	rusty.add_source_edge(0, 10, 0)
	rusty.add_edge(0, 1, 10, 100)
	rusty.add_sink_edge(1, 10, 0)
	
	var paths = rusty.solve()
	
	print(paths)
