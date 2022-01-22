class_name ChartSeries

var name: String
var data: Array
var color: Color

# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
func _init(name: String, data: Array, color: Color):
	self.name = name
	self.data = data
	self.color = color
