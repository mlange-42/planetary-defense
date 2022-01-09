extends Button
class_name LandUseButton

var land_use: int

func _ready():
	self.toggle_mode = true
	
	self.icon = LandUse.LU_ICONS[land_use]
	
	var text = "%s\n %s\n Maintenance: %d\n Workers: %d" \
		% [
			LandUse.LU_NAMES[land_use],
			LandUse.LU_INFO[land_use],
			LandUse.LU_MAINTENANCE[land_use],
			LandUse.LU_WORKERS[land_use]
		]

	var req = LandUse.LU_REQUIREMENTS[land_use]
	
	if not req.empty():
		text += "\n Requires: %s" % req
	
	self.hint_tooltip = text
	
