extends Button
class_name RoadButton

var mode: int

func _ready():
	self.toggle_mode = true
	
	self.icon = Roads.ROAD_ICONS[mode]
	
	var text = "%s\n Costs: %d, Maintenance: %f" \
		% [
			Roads.ROAD_INFO[mode], 
			Roads.ROAD_COSTS[mode], 
			Roads.ROAD_MAINTENANCE_1000[mode] / 1000.0
		]
	
	self.hint_tooltip = text
