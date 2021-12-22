extends ImmediateGeometry


export var radius: float = 10.0
export (int, 0, 6) var subdivisions: int = 6
export var max_height: float = 1.5
export var height_step: float = 0.05
export (String, "", "basic", "billow", "hybrid", "fbm", "ridged") var noise_type: String = ""
export var noise_period: float = 0.5
export var noise_octaves: int = 5
export var height_curve: Curve


func _ready():
	var PlanetGen = preload("res://scripts/native/planet_generator.gdns")
	var planet_gen = PlanetGen.new()
	planet_gen.initialize(radius, subdivisions, max_height, height_step, noise_type, noise_period, noise_octaves, height_curve)
	
	var data = planet_gen.generate()
	
	var mesh: ArrayMesh = data.get_collision_mesh()
	var inst := MeshInstance.new()
	inst.mesh = mesh
	
	add_child(inst)
	
	print(data.get_id_path(0, 100, data.NAV_WATER))
