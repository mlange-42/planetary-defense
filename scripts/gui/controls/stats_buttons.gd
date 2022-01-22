extends PanelContainer

signal stats_panel_selected(panel)

var button_group: ButtonGroup

func _ready():
	button_group = ButtonGroup.new()
	$GridContainer/Charts.group = button_group
	$GridContainer/Flows.group = button_group

func _on_Flows_pressed():
	emit_signal("stats_panel_selected", "flows")
