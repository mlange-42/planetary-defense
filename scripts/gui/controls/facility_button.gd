extends Button
class_name FacilityButton

var facility: String

func _ready():
	self.toggle_mode = true
	self.hint_tooltip = "%s\n %s\n Costs: %d" \
		% [facility, Constants.FACILITY_INFO[facility], Constants.FACILITY_COSTS[facility]]
