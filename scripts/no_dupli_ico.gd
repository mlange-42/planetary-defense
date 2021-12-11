extends MeshInstance

func _ready():
	create_ico()


func create_ico():
	
	var vertices: PoolVector2Array = PoolVector2Array()
	vertices.push_back(Vector2(  0, -58.5))
	vertices.push_back(Vector2(  0,  58.5))
	vertices.push_back(Vector2(180,  58.5))
	vertices.push_back(Vector2(180, -58.5))
	
	vertices.push_back(Vector2( 90, -31.5))
	vertices.push_back(Vector2( 90,  31.5))
	vertices.push_back(Vector2(-90,  31.5))
	vertices.push_back(Vector2(-90, -31.5))
	
	vertices.push_back(Vector2( -31.5, 0))
	vertices.push_back(Vector2(  31.5, 0))
	vertices.push_back(Vector2( 148.5, 0))
	vertices.push_back(Vector2(-148.5, 0))
	
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
	
	var xyz = lla_to_xyz_arr(vertices)
	
	var arr = []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = xyz
	arr[Mesh.ARRAY_INDEX] = indices
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	
	generate_normals(mesh)
	

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
	var vertices: PoolVector3Array = PoolVector3Array()
	vertices.resize(arr.size())
	
	for i in range(arr.size()):
		vertices[i] = lla_to_xyz(arr[i])
	
	return vertices

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
