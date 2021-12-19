extends ImmediateGeometry
class_name DebugDraw

func draw_path(points: Array, color: Color):
	clear()
	begin(Mesh.PRIMITIVE_LINE_STRIP)
	
	set_color(color)
	
	for p in points:
		add_vertex(p + 0.1 * p.normalized())
	
	end()


func draw_roads(nav: NavManager, roads: RoadNetwork, color: Color):
	clear()
	begin(Mesh.PRIMITIVE_LINES)
	
	set_color(color)
	
	for node1 in roads.neighbors:
		var n = roads.neighbors[node1]
		var p1 = nav.get_node(node1).position
		for node2 in n:
			var p2 = nav.get_node(node2).position
			var off = (p2 - p1).cross(p1).normalized() * 0.015
			add_vertex(p1 + 0.02 * p1.normalized() + off)
			add_vertex(p2 + 0.02 * p2.normalized() + off)
	
	end()


func draw_points(nav: NavManager):
	clear()
	begin(Mesh.PRIMITIVE_POINTS)
	
	for data in nav._node_data.values():
		var p = data.position
		set_color(Color.blue if data.is_water else Color.wheat)
		add_vertex(p + 0.025 * p.normalized())
	
	end()
