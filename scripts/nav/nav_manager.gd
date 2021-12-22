class_name NavManager

var nav_land: AStarNavigation
var nav_water: AStarNavigation
var nav_all: AStarNavigation

var _node_data: Dictionary

func _init(vertices: PoolVector3Array, faces: PoolIntArray, planet_radius: float):
	_node_data = generate_node_data(vertices, faces, planet_radius)
	
	nav_land = AStarNavigation.new(vertices, faces, planet_radius, true)
	nav_water = AStarNavigation.new(vertices, faces, planet_radius, false)
	nav_all = AStarNavigation.new(vertices, faces, 0, true)


func get_node(id: int) -> NodeData:
	return _node_data[id]


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
