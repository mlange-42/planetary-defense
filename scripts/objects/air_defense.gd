extends Facility
class_name AirDefense


onready var pole: CSGBox = $Pole

var material: SpatialMaterial

func _ready():
	material = SpatialMaterial.new()
	material.emission_enabled = true
	pole.material = material


func calc_is_supplied():
	.calc_is_supplied()
	var col = Color.green if is_supplied else Color.red
	pole.material.albedo_color = col
	pole.material.emission = col


func can_build(planet_data, node) -> bool:
	return not planet_data.get_node(node).is_water
