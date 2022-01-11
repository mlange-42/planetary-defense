extends Button
class_name FacilityButton

var facility: String

func _ready():
	self.toggle_mode = true
	
	self.icon = Facilities.FACILITY_ICONS[facility]
	
	var text = "%s\n\n %s\n" \
		% [
			facility, 
			Facilities.FACILITY_INFO[facility], 
		]
	
	var base_range = Facilities.FACILITY_RADIUS[facility]
	if base_range > 0:
		text += "\n Base range: %d" % base_range
	
	text += "\n Costs: %d, Maintenance: %d" \
		% [
			Facilities.FACILITY_COSTS[facility], 
			Facilities.FACILITY_MAINTENANCE[facility]
		]
	
	var s = Facilities.FACILITY_SINKS[facility]
	if s != null:
		var line = " Demand: "
		for sink in s:
			line += "%d %s, " % [sink[1], sink[0]]
		text += "\n" + line
	
	self.hint_tooltip = text
