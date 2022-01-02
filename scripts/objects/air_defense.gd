extends Facility
class_name AirDefense

func init(node: int, planet_data):
	.init(node, planet_data)
	
	type = Facilities.FAC_AIR_DEFENSE


func can_build(planet_data, node) -> bool:
	return not planet_data.get_node(node).is_water
