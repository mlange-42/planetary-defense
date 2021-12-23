extends Spatial
class_name Facility

var facility_id: int
var node_id: int

var sources: Dictionary
var sinks: Dictionary
var conversions: Dictionary

var flows: Dictionary

# warning-ignore:unused_argument
func init(node: int, planet_data):
	self.node_id = node

# warning-ignore:unused_argument
func on_ready(planet_data):
	pass
