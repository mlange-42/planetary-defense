extends Facility
class_name MissileBase

func init(node: int, planet_data):
	.init(node, planet_data)
	
	type = Facilities.FAC_MISSILE_BASE


func can_build(planet_data, node) -> bool:
	return not planet_data.get_node(node).is_water
