extends Control
class_name ProductionBar

export var margin: int = 1
export var frame_color: Color = Color.white
export var upper_color: Color = Color.dimgray
export var lower_color: Color = Color.white

var max_value: int = 100
var lower: int = 30
var upper: int = 50

func _ready():
	pass

func _draw():
	var size = get_size()
	
	var mx = max(max_value, 1.0)
	var orig = Vector2(margin, margin)
	var width = size.x - 2 * margin
	var height = size.y - 2 * margin
	
	draw_rect(Rect2(orig, Vector2(width * upper / mx, height)), upper_color, true)
	draw_rect(Rect2(orig, Vector2(width * lower / mx, height)), lower_color, true)
	
	draw_rect(Rect2(orig, Vector2(width, height)), frame_color, false)

func set_values(low: int, up: int, mx: int):
	lower = low
	upper = up
	max_value = mx
	
	update()
