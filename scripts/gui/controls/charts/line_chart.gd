extends Control
class_name LineChart

onready var chart_panel: LineChartPanel = find_node("ChartPanel")
onready var min_label: Label = find_node("MinLabel")
onready var max_label: Label = find_node("MaxLabel")
onready var legend: Container = find_node("Legend")

var legend_entries: Dictionary = {}

func _ready():
	pass


func repaint():
	chart_panel.recalc()
	min_label.text = str(chart_panel.lower.y)
	max_label.text = str(chart_panel.upper.y)
	
	chart_panel.update()


func add_series(ser: ChartSeries):
	if not chart_panel.has_series(ser.name):
		var label = Label.new()
		label.text = ser.name
		label.self_modulate = ser.color
		legend_entries[ser.name] = label
		legend.add_child(label)
	
	chart_panel.add_series(ser)


func remove_series(series_name: String) -> bool:
	if chart_panel.has_series(series_name):
		var label = legend_entries[series_name]
		legend.remove_child(label)
		label.queue_free()
		# warning-ignore: return_value_discarded
		legend_entries.erase(series_name)
	
	return chart_panel.remove_series(series_name)


func clear_series():
	for key in legend_entries.keys():
		# warning-ignore: return_value_discarded
		remove_series(key)
