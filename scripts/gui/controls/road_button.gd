extends Button
class_name RoadButton

var mode: int

func _ready():
	self.toggle_mode = true
	
	self.icon = Network.TYPE_ICONS[mode]
	
	var text = "%s\n %s\n\n Capacity: %d\n Costs: %d\n Maintenance: %s\n Transport cost/1000: %d\n Max. slope: %d" \
		% [
			Network.TYPE_NAMES[mode],
			Network.TYPE_INFO[mode],
			Network.TYPE_CAPACITY[mode],
			Network.TYPE_COSTS[mode], 
			Network.TYPE_MAINTENANCE_1000[mode] / 1000.0,
			Network.TYPE_TRANSPORT_COST_1000[mode],
			Network.TYPE_MAX_SLOPE[mode],
		]
	
	self.hint_tooltip = text
