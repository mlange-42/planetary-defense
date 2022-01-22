extends Control
class_name LineChartPanel


var series: Dictionary = {}

var dirty: bool = false;

var lower: Vector2 = Vector2(0, 0)
var upper: Vector2 = Vector2(0, 0)

func _ready():
	pass


func has_series(series_name: String) -> bool:
	return series.has(series_name)

func add_series(ser: ChartSeries):
	dirty = true
	series[ser.name] = ser

func remove_series(series_name: String) -> bool:
	dirty = true
	return series.erase(series_name)

func clear_series():
	dirty = true
	series.clear()


func recalc():
	if not dirty:
		return
	
	lower.x = 0
	lower.y = 0
	upper.x = 0
	upper.y = 0
	
	for n in series:
		var ser = series[n]
		if ser.data.size() - 1 > upper.x:
			upper.x = ser.data.size() - 1
		for v in ser.data:
			if v > upper.y: upper.y = v
			if v < lower.y: lower.y = v
	
	dirty = false


func _draw():
	recalc()
	
	var origin = to_view(lower)
	draw_line(origin, to_view(Vector2(upper.x, lower.y)), Color.white, 2.0)
	draw_line(origin, to_view(Vector2(lower.x, upper.y)), Color.white, 2.0)
	
	for n in series:
		var ser = series[n]
		for i in range(ser.data.size()-1):
			draw_line(to_view(Vector2(i, ser.data[i])), to_view(Vector2(i+1, ser.data[i+1])), ser.color, 2.0)


func to_view(p: Vector2) -> Vector2:
	return Vector2( \
		rect_size.x * p.x / float(upper.x), \
		rect_size.y - rect_size.y * (p.y - lower.y) / (upper.y - lower.y))
