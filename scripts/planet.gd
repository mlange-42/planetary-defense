extends Spatial

var IcoSphere = preload("res://scripts/ico_sphere/ico_sphere.gd")

export var radius: float = 1.0
export var max_height: float = 0.1
export (int, 0, 6) var subdivisions: int = 2

func _ready():
	var mesh = _create_ground()
	
	var node = MeshInstance.new()
	node.name = "Ground"
	node.mesh = mesh
	
	add_child(node)


func _create_ground() -> Mesh:
	var gen = IcoSphere.new(subdivisions, radius, true)
	var mesh: Mesh = gen.create()
	add_noise(mesh)
	
	return mesh


func add_noise(m: Mesh):
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(m, 0)
	
	var noise := OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 3
	noise.period = 0.25
	noise.persistence = 0.5
	
	print(mdt.get_vertex_normal(0))
	
	for i in range(mdt.get_vertex_count()):
		var vertex: Vector3 = mdt.get_vertex(i)
		var norm = vertex.normalized()
		vertex += norm * noise.get_noise_3dv(vertex) * max_height
		mdt.set_vertex(i, vertex)
	
	m.surface_remove(0)
	mdt.commit_to_surface(m)
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	st.add_smooth_group(true)
	st.append_from(m, 0, Transform.IDENTITY)
	st.generate_normals()
	
	m.surface_remove(0)
	st.commit(m)
