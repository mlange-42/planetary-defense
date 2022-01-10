extends ImmediateGeometry
class_name RoadGeometry


func clear_all():
	clear()


func draw_roads(planet_data, roads: RoadNetwork):
	clear()
	begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for node1 in roads.neighbors:
		var n = roads.neighbors[node1]
		var p1 = planet_data.get_position(node1)
		for node2 in n:
			var edge = roads.edges[[node1, node2]]
			var p2 = planet_data.get_position(node2)
			var direction = (p2 - p1).normalized()
			var x_dir = direction.cross(p1).normalized()
			var x_off = x_dir * Consts.ROAD_WIDTH
			var y_off = direction * (0.1 * Consts.ROAD_WIDTH)
			var h_off = Consts.DRAW_HEIGHT_OFFSET * p1.normalized()
			
			var norm = x_dir.cross(direction)
			
			#set_color(color1.linear_interpolate(color2, edge.flow/float(edge.capacity)))
			
			set_color(Color(edge.flow/float(edge.capacity), 0.0, 0.0))
			
			set_normal(norm)
			
			set_uv(Vector2(1, 1))
			add_vertex(p1 + h_off - y_off)
			
			set_uv(Vector2(0, 1))
			add_vertex(p2 + h_off + y_off)
			
			set_uv(Vector2(0, 0))
			add_vertex(p2 + h_off + y_off + x_off)
			
			
			set_uv(Vector2(0, 0))
			add_vertex(p2 + h_off + y_off + x_off)
			
			set_uv(Vector2(1, 0))
			add_vertex(p1 + h_off - y_off + x_off)
			
			set_uv(Vector2(1, 1))
			add_vertex(p1 + h_off - y_off)
	
	end()
