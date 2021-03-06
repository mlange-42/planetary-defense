extends ImmediateGeometry
class_name RoadGeometry


var road_width: float


func _init(width: float):
	road_width = width


func clear_all():
	clear()


func draw_type(planet_data, roads: NetworkManager, type: int):
	if type == Network.T_POWER_LINE:
		_draw_power_lines(planet_data, roads, type)
	else:
		_draw_roads(planet_data, roads, type)


func _draw_power_lines(planet_data, roads: NetworkManager, type: int):
	clear()
	begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var nothing = Color(0, 0, 0, 0)
	
	var base_height = 6
	var fac_height = 2

	var network = planet_data.get_network()
	
	for i in range(network.get_node_count()):
		var node = network.get_node_at(i)
		var node1 = node[0]
		var n = node[1]
		var nd1 = planet_data.get_node(node1)
		
		var p1 = nd1.position
		var h_scale_1 = fac_height if roads.has_facility(Network.to_base_id(node1)) else base_height
		var h_off_1 = h_scale_1 * road_width * p1.normalized()
		
		var any_edge = false
		for node2 in n:
			var edge = roads.get_edge([node1, node2])
			if edge.net_type != type:
				continue
			
			var nd2 = planet_data.get_node(node2)
			var p2 = nd2.position
			var direction = (p2 - p1).normalized()
			var x_dir = direction.cross(p1).normalized()
			var x_off = x_dir * road_width
			var y_off = direction * (0.25 * road_width)
			
			var h_scale_2 = fac_height if roads.has_facility(Network.to_base_id(node2)) else base_height
			var h_off_2 = h_scale_2 * road_width * p2.normalized()
			
			var cap = float(edge.capacity)
			var flows = roads.get_comm_flows(edge)
			if flows == null:
				set_color(nothing)
			else:
				set_color(Color(flows[0] / cap, flows[1] / cap, flows[2] / cap, flows[3] / cap))
			
			_draw_pipe(p1 + h_off_1 + x_off - y_off, p2 + h_off_2 + x_off + y_off, 0.2 * road_width)
			
			any_edge = true
		
		if any_edge:
			set_color(nothing)
			_draw_pipe(p1, p1 + h_off_1, 0.3 * road_width, true)
		
	end()


func _draw_roads(planet_data, roads: NetworkManager, type: int):
	clear()
	begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var nothing = Color(0, 0, 0, 0)

	var network = planet_data.get_network()
	
	for i in range(network.get_node_count()):
		var node = network.get_node_at(i)
		var node1 = node[0]
		var n = node[1]
		var nd1 = planet_data.get_node(node1)
		
		var p1 = nd1.position
		for node2 in n:
			var edge = roads.get_edge([node1, node2])
			if edge.net_type != type:
				continue
			
			var nd2 = planet_data.get_node(node2)
			
			var p2 = nd2.position
			var direction = (p2 - p1).normalized()
			var x_dir = direction.cross(p1).normalized()
			var x_off = x_dir * road_width
			var y_off = direction * (0.1 * road_width)
			var h_off = Consts.DRAW_HEIGHT_OFFSET * p1.normalized()
			
			var norm = x_dir.cross(direction)
			
			var cap = float(edge.capacity)
			var flows = roads.get_comm_flows(edge)
			if flows == null:
				set_color(nothing)
			else:
				set_color(Color(flows[0] / cap, flows[1] / cap, flows[2] / cap, flows[3] / cap))
			
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


func _draw_pipe(from: Vector3, to: Vector3, radius: float, end_cap: bool = false):
	var direction = (to - from).normalized()
	var x_dir = direction.cross(from).normalized()
	if x_dir == Vector3.ZERO:
		x_dir = direction.cross(Vector3.UP).normalized()
	var y_dir = direction.cross(x_dir)
	
	var dx = x_dir * radius
	var dy = y_dir * radius
	
	set_normal(dx)
	_draw_quad(from + dx, to + dx, dy)
	set_normal(-dx)
	_draw_quad(from - dx, to - dx, -dy)
	
	set_normal(dy)
	_draw_quad(from + dy, to + dy, -dx)
	set_normal(-dy)
	_draw_quad(from - dy, to - dy, dx)
	
	if end_cap:
		set_normal(direction)
		_draw_quad(to - dx, to + dx, -dy)


func _draw_quad(from: Vector3, to: Vector3, right: Vector3):
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
