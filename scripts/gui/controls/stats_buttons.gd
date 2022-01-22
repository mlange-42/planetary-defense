extends PanelContainer
class_name StatsButtons

signal stats_panel_selected(panel)

onready var charts_button: Button = $GridContainer/Charts;
onready var flows_button: Button = $GridContainer/Flows;

var button_group: ButtonGroup
var current = null

func _ready():
	button_group = ButtonGroup.new()
	charts_button.group = button_group
	flows_button.group = button_group


func set_selected(panel):
	current = panel
	if panel == "flows":
		flows_button.pressed = true


func _on_Flows_pressed():
	if current != "flows":
		emit_signal("stats_panel_selected", "flows")
