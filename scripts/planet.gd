extends Spatial

export var random_seed: int = 0
export var radius: float = 1.0
export var max_height: float = 0.1
export var height_curve: Curve
export var noise_period: float = 0.25
export var noise_octaves: int = 3
export (int, 0, 6) var subdivisions: int = 5
export (int, 0, 6) var water_subdivisions: int = 4

export var land_material: Material
export var water_material: Material

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	rng.seed = random_seed
	
	var ground: MeshInstance = _add_mesh(_create_ground(), "Ground")
	ground.material_override = land_material
	
	var water: MeshInstance = _add_mesh(_create_water(), "Water")
	water.material_override = water_material


func _add_mesh(mesh: Mesh, name: String) -> MeshInstance:
	var node = MeshInstance.new()
	node.name = name
	node.mesh = mesh
	add_child(node)
	
	return node


func _create_ground() -> Mesh:
	var gen = IcoSphere.new(subdivisions, radius, true)
	var result: IcoSphere.Result = gen.create([0])
	
	_add_noise(result.mesh)
	
	return result.mesh


func _create_water() -> Mesh:
	var gen = IcoSphere.new(water_subdivisions, radius, true)
	var result: IcoSphere.Result = gen.create([])
	return result.mesh


func _add_noise(m: Mesh):
	var noise := OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = noise_octaves
	noise.period = noise_period * radius
	noise.persistence = 0.5
	
	var height_map: HeightMap = HeightMap.new(rng, noise, max_height, true)
	height_map.create_elevation(m, height_curve, true)
