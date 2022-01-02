extends Facility
class_name MissileBase


func can_build(planet_data, node) -> bool:
	return not planet_data.get_node(node).is_water
