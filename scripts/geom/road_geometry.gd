extends ImmediateGeometry
class_name RoadGeometry


func clear_all():
	clear()


func draw_roads(planet_data, roads: RoadNetwork, land: bool):
	clear()
	begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var neighbors = roads.neighbors()
	
	for node1 in neighbors:
		var n = neighbors[node1]
		var nd1 = planet_data.get_node(node1)
		
		if not land and not nd1.is_water:
			continue
		
		var p1 = nd1.position
		for node2 in n:
			var nd2 = planet_data.get_node(node2)
			
			if not land and not nd2.is_water:
				continue
			
			if land and nd1.is_water and nd2.is_water:
				continue
			
			var edge = roads.get_edge([node1, node2])
			var p2 = nd2.position
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
