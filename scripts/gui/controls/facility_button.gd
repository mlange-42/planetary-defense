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
	
	text += "\n Costs: %d\n Maintenance: %d" \
		% [
			Facilities.FACILITY_COSTS[facility], 
			Facilities.FACILITY_MAINTENANCE[facility]
		]
	
	var s = Facilities.FACILITY_SINKS[facility]
	if s != null:
		var line = " Demand: "
		for sink in s:
			line += "%d %s, " % [sink[1], Commodities.COMM_NAMES[sink[0]]]
		text += "\n" + line.substr(0, line.length()-2)
	
	self.hint_tooltip = text
