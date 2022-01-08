extends PanelContainer
class_name StatsBar

signal next_turn

onready var budget_label = find_node("BudgetLabel")
onready var taxes_label = find_node("TaxesLabel")
onready var maintenance_label = find_node("MaintenanceLabel")
onready var net_label = find_node("NetLabel")
onready var turn_label = find_node("TurnLabel")


func update_finances(planet: Planet):
	var tx = planet.taxes
	
	budget_label.text = str(tx.budget)
	taxes_label.text = str(tx.taxes)
	maintenance_label.text = str(tx.maintenance)
	net_label.text = "%+d" % (tx.taxes - tx.maintenance)
	turn_label.text = str(planet.stats.turn())
	
	maintenance_label.hint_tooltip = "Maintenance\n Facilities: %4d\n Land use:   %4d\n Roads:      %4d\n Transport:  %4d" \
		% [tx.maintenance_facilities, tx.maintenance_land_use, tx.maintenance_roads, tx.maintenance_transport]


func _on_NextTurnButton_pressed():
	emit_signal("next_turn")
