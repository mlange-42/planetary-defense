extends ImmediateGeometry
class_name FlowGraphs

export var flow_width: float = 0.05

var low_color: Color = Color.white
var high_color: Color = Color.purple

func clear_all():
	clear()


func set_colors(c1: Color, c2: Color):
	low_color = c1
	high_color = c2


func get_colors():
	return [low_color, high_color]


func draw_flows(planet_data, flows: Dictionary, commodity: int) -> int:
	clear()
	var max_flow: int = 0
	
	for edge in flows:
		if edge[0] == edge[1]:
			continue
		var edge_flow = flows[edge]
		var f: int = 0
		if commodity < 0:
			for comm in range(edge_flow.size()):
				f += edge_flow[comm]
		else:
			if not commodity in edge_flow:
				continue
			f = edge_flow[commodity]
		if f > max_flow:
			max_flow = f
	
	if max_flow == 0:
		return 0
	
	begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for edge in flows:
		if edge[0] == edge[1]:
			continue
		
		var edge_flow = flows[edge]
		var f: int = 0
		if commodity < 0:
			for comm in range(edge_flow.size()):
				f += edge_flow[comm]
		else:
			f = edge_flow[commodity]
		
		if f == 0:
			continue
		
		set_color(low_color.linear_interpolate(high_color, f / float(max_flow)))
		
		var p1 = planet_data.get_node(edge[0]).position
		var p2 = planet_data.get_node(edge[1]).position
		
		_draw_arc(p1, p2)
	
	end()
	
	return max_flow


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
			var x_off = flow_width * (vert - prev_vert).cross(vert).normalized()
			
			
			add_vertex(prev_vert)
			add_vertex(vert)
			add_vertex(vert + x_off)
			
			add_vertex(vert + x_off)
			add_vertex(prev_vert + x_off)
			add_vertex(prev_vert)
			
			if i == segments / 2:
				var y_off = 4 * flow_width * (vert - prev_vert).normalized()
				add_vertex(vert - y_off + 3 * x_off)
				add_vertex(vert - y_off + x_off)
				add_vertex(vert + x_off)
				
				add_vertex(vert - y_off)
				add_vertex(vert - y_off - 2 * x_off)
				add_vertex(vert)
			
			
		prev_vert = vert
	
	pass
