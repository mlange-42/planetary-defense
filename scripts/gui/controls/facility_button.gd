extends Button
class_name FacilityButton

var facility: String

func _ready():
	self.toggle_mode = true
	self.hint_tooltip = "%s\n %s\n Costs: %d, Maintenance: %d" \
		% [
			facility, 
			Facilities.FACILITY_INFO[facility], 
			Facilities.FACILITY_COSTS[facility], 
			Facilities.FACILITY_MAINTENANCE[facility]
		]
