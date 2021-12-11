extends MeshInstance


var middle_point_cache: Dictionary = {}
var vertices: PoolVector3Array

func _ready():
	create_ico(1)


func create_ico(subdiv):
	
	var verts = PoolVector2Array()
	verts.push_back(Vector2(  0, -58.5))
	verts.push_back(Vector2(  0,  58.5))
	verts.push_back(Vector2(180,  58.5))
	verts.push_back(Vector2(180, -58.5))
	
	verts.push_back(Vector2( 90, -31.5))
	verts.push_back(Vector2( 90,  31.5))
	verts.push_back(Vector2(-90,  31.5))
	verts.push_back(Vector2(-90, -31.5))
	
	verts.push_back(Vector2( -31.5, 0))
	verts.push_back(Vector2(  31.5, 0))
	verts.push_back(Vector2( 148.5, 0))
	verts.push_back(Vector2(-148.5, 0))
	
	vertices = lla_to_xyz_arr(verts)
	
	var indices = PoolIntArray([
		1, 2, 6,
		1, 5, 2,
		5, 10, 2,
		2, 10, 11,
		2, 11, 6,
		7, 6, 11,
		8, 6, 7,
		8, 1, 6,
		9, 1, 8,
		9, 5, 1,
		9, 4, 5,
		4, 10, 5,
		10, 4, 3,
		10, 3, 11,
		11, 3, 7,
		0, 8, 7,
		0, 9, 8,
		4, 9, 0,
		4, 0, 3,
		3, 0, 7
	])
	
	for _i in range(subdiv):
		var indices_subdiv = PoolIntArray()
		for j in range(0, indices.size(), 3):
			var j1 = indices[j]
			var j2 = indices[j+1]
			var j3 = indices[j+2]
			
			var v1 = middle_point(j1, j2)
			var v2 = middle_point(j2, j3)
			var v3 = middle_point(j3, j1)
			
			indices_subdiv.append_array([j1, v1, v3])
			indices_subdiv.append_array([j2, v2, v1])
			indices_subdiv.append_array([j3, v3, v2])
			indices_subdiv.append_array([v1, v2, v3])
			
		indices = indices_subdiv
	
	var arr = []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = vertices
	arr[Mesh.ARRAY_INDEX] = indices
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	
	generate_normals(mesh)


func middle_point(point_1, point_2): 
	var smaller_index = min(point_1, point_2)
	var greater_index = max(point_1, point_2)
	
	var key = [smaller_index, greater_index]
	if key in middle_point_cache:
		return middle_point_cache[key]
	
	var middle: Vector3 = 0.5 * (vertices[point_1] + vertices[point_2])
	
	vertices.append(middle)
	var index = vertices.size() - 1
	middle_point_cache[key] = index
	return index


func generate_normals(mesh):
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# WARNING: doing this without smoothing resultsin duplicate vertices!
	st.add_smooth_group(true)
	st.append_from(mesh, 0, Transform.IDENTITY)
	st.generate_normals()
	
	mesh.surface_remove(0)
	st.commit(mesh)


func lla_to_xyz_arr(arr: PoolVector2Array) -> PoolVector3Array:
	var verts: PoolVector3Array = PoolVector3Array()
	verts.resize(arr.size())
	
	for i in range(arr.size()):
		verts[i] = lla_to_xyz(arr[i])
	
	return verts

func lla_to_xyz(lla: Vector2) -> Vector3:
	var lon = lla.x
	var lat = lla.y
	var cosLat = cos(deg2rad(lat))
	var sinLat = sin(deg2rad(lat))
	var cosLon = cos(deg2rad(lon))
	var sinLon = sin(deg2rad(lon))
	var x = cosLat * cosLon
	var y = sinLat
	var z = cosLat * sinLon
	return Vector3(x, y, z)
