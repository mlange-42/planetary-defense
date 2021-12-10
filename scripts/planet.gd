extends Spatial

onready var IcoSphere = preload("ico_sphere/ico_sphere.gd")
export var radius: float = 1.0
export var subdivisions: int = 2

func _ready():
	var gen = IcoSphere.new(subdivisions, radius)
	var mesh = gen.create()
	
	var node = CSGMesh.new()
	node.mesh = mesh
	
	add_child(node)
