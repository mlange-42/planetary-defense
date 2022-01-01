extends Facility
class_name Port

func init(node: int, planet_data):
	.init(node, planet_data)
	
	type = Constants.FAC_PORT
	planet_data.set_port(node, true)


func save() -> Dictionary:
	var dict = {
		"type": type,
		"name": name,
		"node_id": node_id,
		"city_node_id": city_node_id,
	}
	return dict


func read(dict: Dictionary):
	name = dict["name"]
	node_id = dict["node_id"] as int
	city_node_id = dict["city_node_id"] as int


func can_build(planet_data, node) -> bool:
	var nd = planet_data.get_node(node)
	
	if not nd.is_water:
		return false
	
	var neigh = planet_data.get_neighbors(node)
	for n in neigh:
		if not planet_data.get_node(n).is_water:
			return true
	
	return false
