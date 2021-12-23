extends Spatial
class_name Facility

var facility_id: int
var node_id: int

export var sources: Dictionary
export var sinks: Dictionary
export var conversions: Dictionary

var flows: Dictionary

func init(node: int, planet_data):
	self.node_id = node

func on_ready(planet_data):
	pass
