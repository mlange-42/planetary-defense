extends ImmediateGeometry
class_name RoadGeometry


var road_width: float


func _init(width: float):
	road_width = width


func clear_all():
	clear()


func draw_power_lines(planet_data, roads: NetworkManager, mode: int):
	clear()
	begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for i in range(roads.network.get_node_count()):
		var node = roads.network.get_node_at(i)
		var node1 = node[0]
		var n = node[1]
		var nd1 = planet_data.get_node(node1)
		
		var p1 = nd1.position
		var h_off = 8 * road_width * p1.normalized()
		
		var any_edge = false
		for node2 in n:
			var edge = roads.get_edge([node1, node2])
			var m = Network.TYPE_MODES[edge.net_type]
			if m != mode:
				continue
			
			var nd2 = planet_data.get_node(node2)
			var p2 = nd2.position
			var direction = (p2 - p1).normalized()
			var x_dir = direction.cross(p1).normalized()
			var x_off = x_dir * road_width
			var y_off = direction * (0.25 * road_width)
			
			var flow = edge.flow/float(edge.capacity)
			set_color(Color(flow, 1.0, 0.0))
			draw_pipe(p1 + h_off + x_off - y_off, p2 + h_off + x_off + y_off, 0.2 * road_width)
			
			any_edge = true
		
		if any_edge:
			set_color(Color(0.0, 0.0, 0.0))
			draw_pipe(p1, p1 + h_off, 0.3 * road_width, true)
		
	end()


func draw_roads(planet_data, roads: NetworkManager, mode: int):
	clear()
	begin(Mesh.PRIMITIVE_TRIANGLES)
	
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
			var x_off = x_dir * road_width
			var y_off = direction * (0.1 * road_width)
			var h_off = Consts.DRAW_HEIGHT_OFFSET * p1.normalized()
			
			var norm = x_dir.cross(direction)
			
			#set_color(color1.linear_interpolate(color2, edge.flow/float(edge.capacity)))
			
			set_color(Color(edge.flow/float(edge.capacity), 1.0, 0.0))
			
			set_normal(norm)
			
			set_uv(Vector2(0, 0))
			add_vertex(p1 + h_off - y_off)
			
			set_uv(Vector2(1, 0))
			add_vertex(p2 + h_off + y_off)
			
			set_uv(Vector2(1, 1))
			add_vertex(p2 + h_off + y_off + x_off)
			
			
			set_uv(Vector2(1, 1))
			add_vertex(p2 + h_off + y_off + x_off)
			
			set_uv(Vector2(0, 1))
			add_vertex(p1 + h_off - y_off + x_off)
			
			set_uv(Vector2(0, 0))
			add_vertex(p1 + h_off - y_off)
	
	end()


func draw_pipe(from: Vector3, to: Vector3, radius: float, end_cap: bool = false):
	var direction = (to - from).normalized()
	var x_dir = direction.cross(from).normalized()
	if x_dir == Vector3.ZERO:
		x_dir = direction.cross(Vector3.UP).normalized()
	var y_dir = direction.cross(x_dir)
	
	var dx = x_dir * radius
	var dy = y_dir * radius
	
	set_normal(dx)
	draw_quad(from + dx, to + dx, dy)
	set_normal(-dx)
	draw_quad(from - dx, to - dx, -dy)
	
	set_normal(dy)
	draw_quad(from + dy, to + dy, -dx)
	set_normal(-dy)
	draw_quad(from - dy, to - dy, dx)
	
	if end_cap:
		set_normal(direction)
		draw_quad(to - dx, to + dx, -dy)


func draw_quad(from: Vector3, to: Vector3, right: Vector3):
	set_uv(Vector2(0, 0))
	add_vertex(from - right)
	set_uv(Vector2(1, 0))
	add_vertex(to - right)
	set_uv(Vector2(1, 1))
	add_vertex(to + right)
	
	set_uv(Vector2(1, 1))
	add_vertex(to + right)
	set_uv(Vector2(0, 1))
	add_vertex(from + right)
	set_uv(Vector2(0, 0))
	add_vertex(from - right)
