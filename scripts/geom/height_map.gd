class_name HeightMap

var _rng: RandomNumberGenerator
var _noise: OpenSimplexNoise
var _max_height: float
var _smooth: bool


func _init(rng: RandomNumberGenerator, 
			noise: OpenSimplexNoise, 
			max_height: float, 
			smooth = true):
	self._rng = rng
	self._noise = noise
	self._max_height = max_height
	self._smooth = smooth


func create_elevation(mesh: Mesh, curve: Curve, change_uv: bool = true):
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	
	for i in range(mdt.get_vertex_count()):
		var vertex: Vector3 = mdt.get_vertex(i)
		var norm = vertex.normalized()
		var rel_elevation = 2 * curve.interpolate(_noise.get_noise_3dv(vertex)/2 + 0.5) - 1
		vertex += norm * rel_elevation * _max_height
		mdt.set_vertex(i, vertex)
		
		if change_uv:
			var uv: Vector2 = mdt.get_vertex_uv(i)
			uv.x = 0.5 + 0.5 * rel_elevation
			mdt.set_vertex_uv(i, uv)
	
	mesh.surface_remove(0)
	mdt.commit_to_surface(mesh)
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	if _smooth:
		st.add_smooth_group(true)
	
	st.append_from(mesh, 0, Transform.IDENTITY)
	st.generate_normals()
	
	mesh.surface_remove(0)
	st.commit(mesh)
