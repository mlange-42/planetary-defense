extends Defense
class_name AirDefense

var radius: int

onready var warning = $Warning
onready var range_indicator: RangeIndicator = $RangeIndicator


func _ready():
	intercepts = {
		AirAttack: 0.75,
	}
	
	radius = Facilities.FACILITY_RADIUS[type]


func on_ready(planet_data):
	var temp_cells = planet_data.get_in_radius(node_id, radius)
	for c in temp_cells:
		cells[c[0]] = c[1]
	
	_draw_cells(planet_data)
	calc_is_supplied()


func calc_is_supplied():
	.calc_is_supplied()
	warning.set_shown(not is_supplied)


func can_build(planet_data, node) -> bool:
	return not planet_data.get_node(node).is_water


func _draw_cells(planet_data): 
	range_indicator.draw_range(planet_data, node_id, cells, radius, Color.magenta)
