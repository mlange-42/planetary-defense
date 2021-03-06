extends ImmediateGeometry
class_name DebugDraw


func clear_all():
	clear()


func draw_path(points: Array, max_length: int, color1: Color, color2: Color):
	clear()
	begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var width = Network.TYPE_DRAW_WIDTH[Network.T_ROAD]
	
	set_color(color1)
	
	var length: int = 0
	for i in range(points.size()-1):
		if length == max_length:
			set_color(color2)
		
		var p1 = points[i]
		var p2 = points[i+1]
		
		var direction = (p2 - p1).normalized()
		var x_dir = direction.cross(p1).normalized()
		var x_off = 0.6 * x_dir * width
		var y_off = direction * (0.3 * width)
		var h_off = 2 * Consts.DRAW_HEIGHT_OFFSET * p1.normalized()
		
		var norm = x_dir.cross(direction)
		set_normal(norm)
		
		set_uv(Vector2(1, 1))
		add_vertex(p1 + h_off - y_off - x_off)
		
		set_uv(Vector2(0, 1))
		add_vertex(p2 + h_off + y_off - x_off)
		
		set_uv(Vector2(0, 0))
		add_vertex(p2 + h_off + y_off + x_off)
		
		
		set_uv(Vector2(0, 0))
		add_vertex(p2 + h_off + y_off + x_off)
		
		set_uv(Vector2(1, 0))
		add_vertex(p1 + h_off - y_off + x_off)
		
		set_uv(Vector2(1, 1))
		add_vertex(p1 + h_off - y_off - x_off)
		
		length += 1
	
	end()


func draw_resources(planet_data, resources: ResourceManager):
	clear()
	begin(Mesh.PRIMITIVE_POINTS)
	
	# Dummy vertex, as two points are required for drawing
	_draw_resource(Vector3.ZERO, Resources.RES_OIL)
	
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
