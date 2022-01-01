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
		add_vertex(p + 2 * Consts.DRAW_HEIGHT_OFFSET * p.normalized())
	
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
			var h_off = Consts.DRAW_HEIGHT_OFFSET * p1.normalized()
			
			set_color(color1.linear_interpolate(color2, edge.flow/float(edge.capacity)))
			add_vertex(p1 + h_off - y_off)
			add_vertex(p2 + h_off + y_off)
			add_vertex(p2 + h_off + y_off + x_off)
			
			add_vertex(p2 + h_off + y_off + x_off)
			add_vertex(p1 + h_off - y_off + x_off)
			add_vertex(p1 + h_off - y_off)
	
	end()


func draw_resources(planet_data, resources: ResourceManager):
	clear()
	begin(Mesh.PRIMITIVE_LINES)
	
	for node in resources.resources:
		var res = resources.resources[node]
		var pos: Vector3 = planet_data.get_node(node).position
		var col = Resources.RES_COLORS[res[0]]
		var norm = pos.normalized()
		
		set_color(col)
		add_vertex(pos)
		add_vertex(pos + 0.2 * norm)
	
	end()
