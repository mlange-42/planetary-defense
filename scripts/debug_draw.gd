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
