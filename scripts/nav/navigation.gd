extends AStar
class_name AStarNavigation

func _init(vertices: PoolVector3Array, faces: PoolIntArray):
	for i in range(0, faces.size(), 3):
		for j in range(3):
			var id = faces[i+j]
			if not has_point(id):
				add_point(id, vertices[id])
		
		for j in range(3):
			var id1 = faces[i+j]
			for k in range(3):
				if j != k:
					var id2 = faces[i+k]
					connect_points(id1, id2, false)
