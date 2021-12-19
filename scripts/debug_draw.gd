extends ImmediateGeometry
class_name DebugDraw

export var heigt_offset: float = 0.02
export var road_width: float = 0.05

func draw_path(points: Array, color: Color):
	clear()
	begin(Mesh.PRIMITIVE_LINE_STRIP)
	
	set_color(color)
	
	for p in points:
		add_vertex(p + 2 * heigt_offset * p.normalized())
	
	end()


func draw_roads(nav: NavManager, roads: RoadNetwork, color1: Color, color2: Color):
	clear()
	begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for node1 in roads.neighbors:
		var n = roads.neighbors[node1]
		var p1 = nav.get_node(node1).position
		for node2 in n:
			var edge = roads.edges[[node1, node2]]
			var p2 = nav.get_node(node2).position
			var x_off = (p2 - p1).cross(p1).normalized() * road_width
			var y_off = (p2 - p1).normalized() * (0.5 * road_width)
			var h_off = heigt_offset * p1.normalized()
			
			set_color(color1.linear_interpolate(color2, edge.flow/float(edge.capacity)))
			add_vertex(p1 + h_off - y_off)
			add_vertex(p2 + h_off + y_off)
			add_vertex(p2 + h_off + y_off + x_off)
			
			add_vertex(p2 + h_off + y_off + x_off)
			add_vertex(p1 + h_off - y_off + x_off)
			add_vertex(p1 + h_off - y_off)
	
	end()


func draw_points(nav: NavManager):
	clear()
	begin(Mesh.PRIMITIVE_POINTS)
	
	for data in nav._node_data.values():
		var p = data.position
		set_color(Color.blue if data.is_water else Color.wheat)
		add_vertex(p + heigt_offset * p.normalized())
	
	end()
