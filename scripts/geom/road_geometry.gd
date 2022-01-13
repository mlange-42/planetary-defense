extends ImmediateGeometry
class_name RoadGeometry


func clear_all():
	clear()


func draw_simple(planet_data, roads: NetworkManager, mode: int, color1: Color, color2: Color):
	clear()
	begin(Mesh.PRIMITIVE_LINES)
	
	set_color(color1)
	
	for i in range(roads.network.get_node_count()):
		var node = roads.network.get_node_at(i)
		var node1 = node[0]
		var n = node[1]
		var nd1 = planet_data.get_node(node1)
		
		var p1 = nd1.position
		for node2 in n:
			var edge = roads.get_edge([node1, node2])
			var m = Network.TYPE_MODES[edge.net_type]
			if m != mode:
				continue
			
			var nd2 = planet_data.get_node(node2)
			var p2 = nd2.position
			var direction = (p2 - p1).normalized()
			var x_dir = direction.cross(p1).normalized()
			var x_off = x_dir * 0.4 * Consts.ROAD_WIDTH
			var h_off = 10 * Consts.DRAW_HEIGHT_OFFSET * p1.normalized()
			
			set_color(color1.linear_interpolate(color2, edge.flow / float(edge.capacity)))
			
			add_vertex(p1 + h_off + x_off)
			add_vertex(p2 + h_off + x_off)
			
			add_vertex(p1)
			add_vertex(p1 + h_off)
			
			add_vertex(p1 + h_off + x_off)
			add_vertex(p1 + h_off - x_off)
	end()


func draw_roads(planet_data, roads: NetworkManager, mode: int, land: bool):
	clear()
	begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for i in range(roads.network.get_node_count()):
		var node = roads.network.get_node_at(i)
		var node1 = node[0]
		var n = node[1]
		var nd1 = planet_data.get_node(node1)
		
		if not land and not nd1.is_water:
			continue
		
		var p1 = nd1.position
		for node2 in n:
			var edge = roads.get_edge([node1, node2])
			var m = Network.TYPE_MODES[edge.net_type]
			if m != mode:
				continue
			
			var nd2 = planet_data.get_node(node2)
			
			if not land and not nd2.is_water:
				continue
			
			if land and nd1.is_water and nd2.is_water:
				continue
			
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
