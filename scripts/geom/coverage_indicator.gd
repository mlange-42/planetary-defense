extends MeshInstance
class_name CoverageIndicator

var segments: int = 24
var radius: float = 10


# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
func _init(segments: int, radius: float):
	self.segments = segments
	self.radius = radius
	_create_mesh()


func set_coverage(angle: float):
	pass


func _create_mesh():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINE_LOOP)
	
	var step = 360.0 / float(segments)
	for i in segments:
		var angle = i * step
		var v = GeoUtil.lla_to_xyz(Vector2(angle, 45)) * radius
		st.add_vertex(Vector3(v.x, v.z, -v.y))
	
	self.mesh = st.commit()
