extends Button
class_name LandUseButton

export (int, "None", "Crops", "Forest", "Factory") var land_use: int

func _ready():
	self.toggle_mode = true
