extends Button
class_name RoadButton

var mode: int

func _ready():
	self.toggle_mode = true
	
	self.icon = Network.TYPE_ICONS[mode]
	
	var text = "%s\n\n Capacity: %d\n Costs: %d, Maintenance: %s" \
		% [
			Network.TYPE_INFO[mode], 
			Network.TYPE_CAPACITY[mode],
			Network.TYPE_COSTS[mode], 
			Network.TYPE_MAINTENANCE_1000[mode] / 1000.0
		]
	
	self.hint_tooltip = text
