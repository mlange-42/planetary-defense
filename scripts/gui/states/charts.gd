extends GuiState
class_name ChartsState

onready var stats_buttons: StatsButtons = find_node("StatsButtons")
onready var chart: LineChart = find_node("LineChart")

var button_group: ButtonGroup

func _ready():
	stats_buttons.set_selected("charts")
	
	button_group = ButtonGroup.new()
	find_node("Production").group = button_group
	find_node("Population").group = button_group
	find_node("Finances").group = button_group
	
	# warning-ignore:return_value_discarded
	button_group.connect("pressed", self, "_on_chart_changed")
	
	find_node("Production").pressed = true


func _on_chart_changed(button):
	if button.name == "Production":
		draw_production()
	elif button.name == "Population":
		draw_population()
	elif button.name == "Finances":
		draw_finances()


func draw_production():
	chart.clear_series()
	
	for c in Commodities.COMM_ALL:
		var data = StatsManager.unfold(fsm.planet.stats.potential_production[c])
		chart.add_series(ChartSeries.new("%s (pot)" % Commodities.COMM_NAMES[c], data, Commodities.COMM_COLORS[c], 1))
		
		data = StatsManager.unfold(fsm.planet.stats.production[c])
		chart.add_series(ChartSeries.new(Commodities.COMM_NAMES[c], data, Commodities.COMM_COLORS[c], 3))
		
	chart.repaint()


func draw_population():
	chart.clear_series()
	
	var data = StatsManager.unfold(fsm.planet.stats.population)
	chart.add_series(ChartSeries.new("Population", data, Color.lightblue, 2))
	data = StatsManager.unfold(fsm.planet.stats.unemployed)
	chart.add_series(ChartSeries.new("Unemployed", data, Color.orange, 2))
	
	chart.repaint()


func draw_finances():
	chart.clear_series()
	
	var data = StatsManager.unfold(fsm.planet.stats.taxes)
	chart.add_series(ChartSeries.new("Taxes", data, Color.green, 2))
	data = StatsManager.unfold(fsm.planet.stats.maintenance)
	chart.add_series(ChartSeries.new("Maintenance", data, Color.orange, 2))
	data = StatsManager.unfold(fsm.planet.stats.income)
	chart.add_series(ChartSeries.new("Income", data, Color.lightblue, 2))
	
	chart.repaint()


func _on_stats_panel_selected(panel):
	fsm.pop()
	fsm.push(panel, {})


func _on_BackButton_pressed():
	fsm.pop()
