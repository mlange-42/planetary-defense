class_name UvSphere

var verbose = ProjectSettings.get_setting("debug/settings/stdout/verbose_stdout")

var rings: int
var segments: int
var radius: float

# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
func _init(rings: int, segments: int, radius: float = 1):
	self.rings = rings
	self.segments = segments
	self.radius = radius


func create() -> Mesh:
	var sphere = SphereMesh.new()
	sphere.radius = 1.0
	sphere.rings = rings
	sphere.radial_segments = segments
	
	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, sphere.get_mesh_arrays())
	
	var mdt := MeshDataTool.new()
	# warning-ignore:return_value_discarded
	mdt.create_from_surface(mesh, 0)
	
	for i in range(mdt.get_vertex_count()):
		mdt.set_vertex_normal(i, mdt.get_vertex(i))
		if radius != 1.0:
			mdt.set_vertex(i, mdt.get_vertex(i) * radius)
	
	# warning-ignore:return_value_discarded
	mdt.commit_to_surface(mesh)
	
	return mesh
