extends ImmediateGeometry
class_name DebugDraw

func draw_path(points: PoolVector3Array, color: Color):
	clear()
	begin(Mesh.PRIMITIVE_LINE_STRIP)
	
	set_color(color)
	
	for p in points:
		add_vertex(p + 0.5 * p.normalized())
	
	end()
