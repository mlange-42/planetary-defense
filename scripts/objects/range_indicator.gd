extends ImmediateGeometry
class_name RangeIndicator

func draw_range(planet_data, center: int, cells: Dictionary, radius: int, color: Color):
	var border_cells = []
	
	for c in cells:
		if cells[c] == radius:
			border_cells.append(planet_data.get_position(c))
	
	var origin = planet_data.get_position(center)
	
	GeoUtil.sort_by_angle(border_cells, origin, origin.normalized())
	
	self.clear()
	self.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	self.set_color(color)
	
	var rad = planet_data.get_cell_radius()
	
	for i in range(border_cells.size()):
		var p1 = border_cells[i]
		var p2 = border_cells[(i + 1) % border_cells.size()]
		var n1 = (p1 - origin).normalized()
		var n2 = (p2 - origin).normalized()
		
		self.set_uv(Vector2(0, 0))
		self.add_vertex(self.to_local(p1 + 3 * Consts.DRAW_HEIGHT_OFFSET * p1.normalized() + rad * n1))
		
		self.set_uv(Vector2(1, 0))
		self.add_vertex(self.to_local(p1 + 3 * Consts.DRAW_HEIGHT_OFFSET * p1.normalized()))
		
		self.set_uv(Vector2(0, 0))
		self.add_vertex(self.to_local(p2 + 3 * Consts.DRAW_HEIGHT_OFFSET * p2.normalized() + rad * n2))
		
		self.set_uv(Vector2(1, 0))
		self.add_vertex(self.to_local(p2 + 3 * Consts.DRAW_HEIGHT_OFFSET * p2.normalized()))
	
	self.end()
