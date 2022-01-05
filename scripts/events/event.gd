class_name Event

var node_id: int = -1


func select_target(_planet):
	pass


func init(_planet):
	pass


func do_effect(_planet):
	pass


func has_target() -> bool:
	return node_id >= 0


func delete(_planet):
	pass


func save() -> Dictionary:
	return {
		"script": get_script().resource_path,
		"node": node_id,
	}


func read(dict: Dictionary):
	node_id = dict["node"] as int
