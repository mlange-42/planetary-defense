extends Button
class_name RoadButton

var mode: int

func _ready():
	self.toggle_mode = true
	
	self.icon = Network.ROAD_ICONS[mode]
	
	var text = "%s\n\n Capacity: %d\n Costs: %d, Maintenance: %s" \
		% [
			Network.ROAD_INFO[mode], 
			Network.ROAD_CAPACITY[mode],
			Network.ROAD_COSTS[mode], 
			Network.ROAD_MAINTENANCE_1000[mode] / 1000.0
		]
	
	self.hint_tooltip = text
