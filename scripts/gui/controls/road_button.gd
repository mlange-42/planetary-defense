extends Button
class_name RoadButton

var mode: int

func _ready():
	self.toggle_mode = true
	
	self.icon = Roads.ROAD_ICONS[mode]
	
	var text = "%s\n\n Capacity: %d\n Costs: %d, Maintenance: %s" \
		% [
			Roads.ROAD_INFO[mode], 
			Roads.ROAD_CAPACITY[mode],
			Roads.ROAD_COSTS[mode], 
			Roads.ROAD_MAINTENANCE_1000[mode] / 1000.0
		]
	
	self.hint_tooltip = text
