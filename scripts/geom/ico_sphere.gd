class_name IcoSphere

var verbose = ProjectSettings.get_setting("debug/settings/stdout/verbose_stdout")

var subdivisions: int
var radius: float
var smooth: bool

var vertices: PoolVector3Array

class Result:
	var mesh: Mesh
	var subdiv_faces: Dictionary

# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
func _init(subdivisions: int, radius: float = 1, smooth = true):
	self.subdivisions = subdivisions
	self.radius = radius
	self.smooth = smooth


func create(track_subdivs: Array) -> Result:
	var result = Result.new()
	var cache := Dictionary()
	
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
	
	if track_subdivs.has(0):
		result.subdiv_faces[0] = indices
	
	for i in range(subdivisions):
		var indices_subdiv = PoolIntArray()
		for j in range(0, indices.size(), 3):
			var j1 = indices[j]
			var j2 = indices[j+1]
			var j3 = indices[j+2]
			
			var v1 = middle_point(j1, j2, cache)
			var v2 = middle_point(j2, j3, cache)
			var v3 = middle_point(j3, j1, cache)
			
			indices_subdiv.append_array([j1, v1, v3])
			indices_subdiv.append_array([j2, v2, v1])
			indices_subdiv.append_array([j3, v3, v2])
			indices_subdiv.append_array([v1, v2, v3])
			
		indices = indices_subdiv
		if track_subdivs.has(i+1):
			result.subdiv_faces[i+1] = indices
	
	var normals = PoolVector3Array(vertices)
	var uv = GeoUtil.calc_sphere_uv(vertices)
	
	# scale vertices to radius
	if radius != 1.0:
		scale_vertices(radius)
	
	var arr = []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = vertices
	arr[Mesh.ARRAY_NORMAL] = normals
	arr[Mesh.ARRAY_TEX_UV] = uv
	arr[Mesh.ARRAY_TEX_UV2] = PoolVector2Array(uv)
	arr[Mesh.ARRAY_INDEX] = indices
	
	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	
	if not smooth:
		split_unsmooth(mesh)
	
	if verbose:
		var arrs = mesh.surface_get_arrays(0)
		print("Generated Ico Sphere with %d vertices and %d faces" 
				% [arrs[Mesh.ARRAY_VERTEX].size(), arrs[Mesh.ARRAY_INDEX].size() / 3])
	
	result.mesh = mesh
	return result


func split_unsmooth(mesh: Mesh):
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	st.append_from(mesh, 0, Transform.IDENTITY)
	st.generate_normals()
	
	mesh.surface_remove(0)
	st.commit(mesh)


func middle_point(point_1: int, point_2: int, cache: Dictionary): 
	var smaller_index = min(point_1, point_2)
	var greater_index = max(point_1, point_2)
	
	var key = [smaller_index, greater_index]
	if key in cache:
		return cache[key]
	
	var middle: Vector3 = (0.5 * (vertices[point_1] + vertices[point_2])).normalized()
	
	vertices.append(middle)
	var index = vertices.size() - 1
	cache[key] = index
	return index


func scale_vertices(rad: float):
	for i in range(vertices.size()):
		vertices[i] *= rad


func lla_to_xyz_arr(arr: PoolVector2Array) -> PoolVector3Array:
	var verts: PoolVector3Array = PoolVector3Array()
	verts.resize(arr.size())
	
	for i in range(arr.size()):
		verts[i] = GeoUtil.lla_to_xyz(arr[i])
	
	return verts

