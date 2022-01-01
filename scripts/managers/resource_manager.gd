class_name ResourceManager

var planet_data = null

var resources: Dictionary = {}

# warning-ignore:shadowed_variable
func _init(planet_data):
	self.planet_data = planet_data


func generate_resources():
	pass


func save() -> Dictionary:
	return {
		"resources": resources
	}


func read(dict: Dictionary):
	print(dict)
	var res = dict["resources"] as Dictionary
	
	for node in res:
		var val = res[node]
		self.resources[node as int] = [val[0] as int, val[1] as int]
