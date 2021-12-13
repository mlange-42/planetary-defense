class_name NavManager

var nav_land: AStarNavigation
var node_data: Dictionary

class NodeData:
	var is_water: bool
	var height: float
	var position: Vector3

func _init(vertices: PoolVector3Array, faces: PoolIntArray, planet_radius: float):
	node_data = generate_node_data(vertices, faces, planet_radius)
	
	nav_land = AStarNavigation.new(vertices, faces, planet_radius, true)


func generate_node_data(vertices: PoolVector3Array, faces: PoolIntArray, planet_radius: float) -> Dictionary:
	var dict = Dictionary()
	
	for id in faces:
		if not dict.has(id):
			var v = vertices[id]
			var data = NodeData.new()
			var h = v.length() - planet_radius
			data.is_water = h <= 0
			data.height = h if h >= 0 else 0
			data.position = v if h >= 0 else (v.normalized() * planet_radius)
			
			dict[id] = data
		
	
	return dict
