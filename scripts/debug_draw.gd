extends ImmediateGeometry
class_name DebugDraw

export var road_width: float = 0.05


func clear_all():
	clear()


func draw_path(points: Array, color: Color):
	clear()
	begin(Mesh.PRIMITIVE_LINE_STRIP)
	
	set_color(color)
	
	for p in points:
		add_vertex(p + 2 * Constants.DRAW_HEIGHT_OFFSET * p.normalized())
	
	end()


func draw_roads(planet_data, roads: RoadNetwork, color1: Color, color2: Color):
	clear()
	begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for node1 in roads.neighbors:
		var n = roads.neighbors[node1]
		var p1 = planet_data.get_position(node1)
		for node2 in n:
			var edge = roads.edges[[node1, node2]]
			var p2 = planet_data.get_position(node2)
			var x_off = (p2 - p1).cross(p1).normalized() * road_width
			var y_off = (p2 - p1).normalized() * (0.5 * road_width)
			var h_off = Constants.DRAW_HEIGHT_OFFSET * p1.normalized()
			
			set_color(color1.linear_interpolate(color2, edge.flow/float(edge.capacity)))
			add_vertex(p1 + h_off - y_off)
			add_vertex(p2 + h_off + y_off)
			add_vertex(p2 + h_off + y_off + x_off)
			
			add_vertex(p2 + h_off + y_off + x_off)
			add_vertex(p1 + h_off - y_off + x_off)
			add_vertex(p1 + h_off - y_off)
	
	end()


func draw_flows(planet_data, flows: Dictionary, commodity: String, color1: Color, color2: Color):
	clear()
	
	var max_flow: int = 0
	
	for edge in flows:
		if edge[0] == edge[1]:
			continue
		var edge_flow = flows[edge]
		if not commodity in edge_flow:
			continue
		var f = edge_flow[commodity]
		if f > max_flow:
			max_flow = f
	
	if max_flow == 0:
		return
	
	begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for edge in flows:
		if edge[0] == edge[1]:
			continue
		
		var edge_flow = flows[edge]
		if not commodity in edge_flow:
			continue
		var f = edge_flow[commodity]
		if f == 0:
			continue
		
		set_color(color1.linear_interpolate(color2, f / float(max_flow)))
		
		var p1 = planet_data.get_node(edge[0]).position
		var p2 = planet_data.get_node(edge[1]).position
		
		_draw_arc(p1, p2)
	
	end()

func _draw_arc(p1: Vector3, p2: Vector3):
	var rad1 = p1.length()
	var rad2 = p2.length()
	var rad_diff = rad2 - rad1
	var height = min(rad1, rad2) * 0.05
	
	var n1 = p1.normalized()
	var n2 = p2.normalized()
	
	var prev_vert = null
	var segments = 20
	for i in range(segments + 1):
		var t = i / float(segments)
		var omega = acos(n1.dot(n2))
		var d = sin(omega)
		var s1 = sin((1.0 - t) * omega)
		var s2 = sin(t * omega)
		
		var h = 1.0 - pow(2.0 * t - 1.0, 2)
		var rad = rad1 + t * rad_diff + h * height
		var vert = rad * (n1 * s1 + n2 * s2) / d
		
		if prev_vert != null:
			var x_off = road_width * (vert - prev_vert).cross(vert).normalized()
			
			
			add_vertex(prev_vert)
			add_vertex(vert)
			add_vertex(vert + x_off)
			
			add_vertex(vert + x_off)
			add_vertex(prev_vert + x_off)
			add_vertex(prev_vert)
			
			if i == segments / 2:
				var y_off = 4 * road_width * (vert - prev_vert).normalized()
				add_vertex(vert - y_off + 3 * x_off)
				add_vertex(vert - y_off + x_off)
				add_vertex(vert + x_off)
				
				add_vertex(vert - y_off)
				add_vertex(vert - y_off - 2 * x_off)
				add_vertex(vert)
			
			
		prev_vert = vert
	
	pass
