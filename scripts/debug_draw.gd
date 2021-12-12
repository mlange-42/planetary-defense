extends ImmediateGeometry
class_name DebugDraw

func draw_path(points: Array, color: Color):
	clear()
	begin(Mesh.PRIMITIVE_LINE_STRIP)
	
	set_color(color)
	
	for p in points:
		add_vertex(p + 0.5 * p.normalized())
	
	end()

func draw_points(nav: AStar, color: Color):
	clear()
	begin(Mesh.PRIMITIVE_POINTS)
	
	set_color(color)
	
	for i in nav.get_points():
		var p = nav.get_point_position(i)
		add_vertex(p)
	
	end()
