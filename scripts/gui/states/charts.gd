extends GuiState
class_name ChartsState

onready var stats_buttons: StatsButtons = find_node("StatsButtons")
onready var chart: LineChart = find_node("LineChart")

func _ready():
	stats_buttons.set_selected("charts")
	
	for c in Commodities.COMM_ALL:
		var data = fsm.planet.stats.production[c]
		chart.add_series(ChartSeries.new(Commodities.COMM_NAMES[c], data, Commodities.COMM_COLORS[c]))
	chart.repaint()


func _on_stats_panel_selected(panel):
	fsm.pop()
	fsm.push(panel, {})


func _on_BackButton_pressed():
	fsm.pop()
