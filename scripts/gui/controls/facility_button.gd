extends Button
class_name FacilityButton

var facility: String

func _ready():
	self.toggle_mode = true
	
	self.icon = load(Facilities.FACILITY_ICONS[facility])
	
	var text = "%s\n %s\n Costs: %d, Maintenance: %d" \
		% [
			facility, 
			Facilities.FACILITY_INFO[facility], 
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
