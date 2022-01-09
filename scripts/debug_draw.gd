extends ImmediateGeometry
class_name DebugDraw


func clear_all():
	clear()


func draw_path(points: Array, max_length: int, color1: Color, color2: Color):
	clear()
	begin(Mesh.PRIMITIVE_LINE_STRIP)
	
	set_color(color1)
	
	var length: int = 0
	for p in points:
		add_vertex(p + 2 * Consts.DRAW_HEIGHT_OFFSET * p.normalized())
		if length == max_length:
			set_color(color2)
			add_vertex(p + 2 * Consts.DRAW_HEIGHT_OFFSET * p.normalized())
		length += 1
	
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
			var direction = (p2 - p1).normalized()
			var x_dir = direction.cross(p1).normalized()
			var x_off = x_dir * Consts.ROAD_WIDTH
			var y_off = direction * (0.5 * Consts.ROAD_WIDTH)
			var h_off = Consts.DRAW_HEIGHT_OFFSET * p1.normalized()
			
			var norm = x_dir.cross(direction)
			
			set_color(color1.linear_interpolate(color2, edge.flow/float(edge.capacity)))
			
			set_normal(norm)
			add_vertex(p1 + h_off - y_off)
			add_vertex(p2 + h_off + y_off)
			add_vertex(p2 + h_off + y_off + x_off)
			
			add_vertex(p2 + h_off + y_off + x_off)
			add_vertex(p1 + h_off - y_off + x_off)
			add_vertex(p1 + h_off - y_off)
	
	end()


func draw_resources(planet_data, resources: ResourceManager):
	clear()
	begin(Mesh.PRIMITIVE_POINTS)
	
	for node in resources.resources:
		var res = resources.resources[node]
		var pos: Vector3 = planet_data.get_position(node)
		
		_draw_resource(pos, res[0])
	
	end()


func _draw_resource(pos: Vector3, type: int):
	var col = Resources.RES_COLORS[type]
	var norm = pos.normalized()
	
	set_color(col)
	add_vertex(pos + Consts.DRAW_HEIGHT_OFFSET * norm)
