class_name ResourceManager

var planet_data = null

var resources: Dictionary = {}

# warning-ignore:shadowed_variable
func _init(planet_data):
	self.planet_data = planet_data


func generate_resources():
	var max_elevation = float(planet_data.get_max_elevation())
	var veg_nodes = []
	
	for _i in range(LandUse.VEG_NAMES.size()):
		veg_nodes.append([])
	
	for n in range(planet_data.get_node_count()):
		var node = planet_data.get_node(n)
		var veg = node.vegetation_type
		var ele = node.elevation / max_elevation
		veg_nodes[veg].append([n, ele])
	
	for res in LandUse.VEG_RESOURCES:
		var entries = LandUse.VEG_RESOURCES[res]
		
		for veg in entries:
			var params = entries[veg]
			var rad = params["radius"]
			var amount = params["amount"]
			var prob = params["probability"]
			var height = params["elevation"]
			var all_nodes = veg_nodes[veg]
			var nodes = []
			for ne in all_nodes:
				if ne[1] > height[0] and ne[1] < height[1]:
					nodes.append(ne[0])
			
			nodes.shuffle()
			var expected = int(ceil(nodes.size() * prob))
			
			for i in range(min(expected, nodes.size())):
				add_resources(nodes[i], rad, res, amount)


func add_resources(node: int, radius: int, type: int, amount: int):
	var nodes = planet_data.get_in_radius(node, radius)
	for n in nodes:
		if not resources.has(n[0]):
			resources[n[0]] = [type, amount]


func has_resource(node: int, type: int) -> bool:
	if resources.has(node):
		var res = resources[node]
		return res[0] == type
	else:
		return false


func extract_resource(node: int, type: int, amount: int) -> int:
	var value = 0
	
	if resources.has(node):
		var res = resources[node]
		if res[0] == type:
			var v = min(res[1], amount)
			if v == res[1]:
				# warning-ignore:return_value_discarded
				resources.erase(node)
			else:
				res[1] -= v
			value = v
	
	return value


func can_extract_resource(node: int, type: int, amount: int) -> int:
	var value = 0
	
	if resources.has(node):
		var res = resources[node]
		if res[0] == type:
			var v = min(res[1], amount)
			value = v
	
	return value


func save() -> Dictionary:
	return {
		"resources": resources
	}


func read(dict: Dictionary):
	var res = dict["resources"] as Dictionary
	
	for node in res:
		var val = res[node]
		self.resources[node as int] = [val[0] as int, val[1] as int]
