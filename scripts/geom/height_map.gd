class_name HeightMap

var _rng: RandomNumberGenerator
var _noise: OpenSimplexNoise
var _max_height: float


func _init(rng: RandomNumberGenerator, 
			noise: OpenSimplexNoise, 
			max_height: float):
	self._rng = rng
	self._noise = noise
	self._max_height = max_height


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
	
	_calc_normals(mdt)
	
	mesh.surface_remove(0)
	mdt.commit_to_surface(mesh)


func _calc_normals(mdt: MeshDataTool):
	for i in range(mdt.get_vertex_count()):
		mdt.set_vertex_normal(i, Vector3.ZERO)
	
	for i in range(mdt.get_face_count()):
		var id1 = mdt.get_face_vertex(i, 0)
		var id2 = mdt.get_face_vertex(i, 1)
		var id3 = mdt.get_face_vertex(i, 2)
		var norm = _calc_face_normal(mdt.get_vertex(id1), mdt.get_vertex(id2), mdt.get_vertex(id3))
		
		mdt.set_vertex_normal(id1, mdt.get_vertex_normal(id1) + norm)
		mdt.set_vertex_normal(id2, mdt.get_vertex_normal(id2) + norm)
		mdt.set_vertex_normal(id3, mdt.get_vertex_normal(id3) + norm)
		
	for i in range(mdt.get_vertex_count()):
		mdt.set_vertex_normal(i, mdt.get_vertex_normal(i).normalized())

func _calc_face_normal(v1: Vector3, v2: Vector3, v3: Vector3) -> Vector3:
	var u = (v2 - v1)
	var v = (v3 - v1)
	
	return v.cross(u).normalized()
	
