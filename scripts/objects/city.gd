extends Facility
class_name City

onready var label: Label = $Sprite3D/Viewport/Label
onready var borders: ImmediateGeometry = $Borders

var cells: Dictionary = {}
var land_use: Dictionary = {}
var radius: int = 1
var workers: int = 6

var commodity_weights: Array = [100, 100, 100]
var auto_assign_workers: bool = true

func init(node: int, planet_data):
	.init(node, planet_data)


func on_ready(planet_data):
	var sprite = $Sprite3D
	
	sprite.texture = $Sprite3D/Viewport.get_texture()
	sprite.texture.set_flags(Texture.FLAG_FILTER | Texture.FLAG_MIPMAPS)
	
	update_cells(planet_data)


func update_cells(planet_data):
	cells.clear()
	var temp_cells = planet_data.get_in_radius(node_id, radius)
	for c in temp_cells:
		cells[c[0]] = c[1]
	
	update_visuals(planet_data)


func update_visuals(planet_data):
	label.text = "%s (%d)" % [name, workers]
	_draw_cells(planet_data)


func set_label_visible(vis: bool):
	$Sprite3D.visible = vis


func _draw_cells(planet_data): 
	borders.clear()
	borders.begin(Mesh.PRIMITIVE_POINTS)
	
	borders.set_color(Color.white)
	
	for c in cells:
		if cells[c] == radius and not c in land_use:
			var p = planet_data.get_position(c)
			borders.set_color(Color.dimgray)
			borders.add_vertex(self.to_local(p + Constants.DRAW_HEIGHT_OFFSET * p.normalized()))
	
	for c in land_use:
		var p = planet_data.get_position(c)
		borders.set_color(Constants.LU_COLORS[land_use[c]])
		borders.add_vertex(self.to_local(p + 2 * Constants.DRAW_HEIGHT_OFFSET * p.normalized()))
	
	borders.end()
