extends AStar
class_name AStarNavigation

var verbose = ProjectSettings.get_setting("debug/settings/stdout/verbose_stdout")

func _init(vertices: PoolVector3Array, faces: PoolIntArray, 
			height_threshold: float, above: float = true, correct_height: float = false):
	var thres_sq = height_threshold * height_threshold
	
	for i in range(0, faces.size(), 3):
		for j in range(3):
			var id = faces[i+j]
			var vert: Vector3 = vertices[id]
			if not has_point(id):
				if (above and vert.length_squared() > thres_sq) \
						or (not above and vert.length_squared() <= thres_sq):
					if correct_height:
						add_point(id, vert.normalized() * height_threshold)
					else:
						add_point(id, vert)
				
		
		for j in range(3):
			var id1 = faces[i+j]
			var vert1: Vector3 = vertices[id1]
			for k in range(3):
				if j != k:
					var id2 = faces[i+k]
					var vert2: Vector3 = vertices[id2]
					if above:
						if vert1.length_squared() > thres_sq and vert2.length_squared() > thres_sq:
							connect_points(id1, id2, false)
					else:
						if vert1.length_squared() <= thres_sq and vert2.length_squared() <= thres_sq:
							connect_points(id1, id2, false)
						
	if verbose:
		print("Populated nav graph with %d nodes" % get_point_count())
