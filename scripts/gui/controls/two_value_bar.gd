extends Control
class_name TwoValueBar

export var margin: int = 1
export var frame_color: Color = Color.white
export var bar_color: Color = Color.dimgray
export var bar_above_color: Color = Color(1.0, 0.28, 0.28)
export var notch_color: Color = Color.white

export var notch_radius: float = 0.5

var max_value: int = 100
var bar_value: int = 30
var notch_value: int = 50

func _ready():
	pass

func _draw():
	var size = get_size()
	
	var mx = max(max_value, 1.0)
	var orig = Vector2(margin, margin)
	var width = size.x - 2 * margin
	var height = size.y - 2 * margin
	
	var x_bar = width * bar_value / mx
	var x_notch = width * notch_value / mx
	
	draw_rect(Rect2(orig, Vector2(x_bar, height)), bar_color, true)
	
	if bar_value > notch_value:
		draw_rect(Rect2(Vector2(orig.x + x_notch, orig.y), Vector2(x_bar - x_notch, height)), bar_above_color, true)
	
	draw_rect(Rect2(Vector2(orig.x + x_notch - notch_radius, orig.y), Vector2(2 * notch_radius + 1, height)), notch_color, true)
	
	draw_rect(Rect2(orig, Vector2(width, height)), frame_color, false)

func set_values(bar: int, notch: int, mx: int):
	bar_value = bar
	notch_value = notch
	max_value = mx
	
	update()
