extends Spatial
class_name LandUseNode

var node_id: int = 0
var land_use: int = 0

func _init(node: int, lu: int):
	node_id = node
	land_use = lu
	
	var child: Spatial = load(LandUse.LU_SCENES[lu]).instance()
	child.rotate_x(deg2rad(-90))
	add_child(child)
