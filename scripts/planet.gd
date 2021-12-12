extends Spatial

export var random_seed: int = 0
export var radius: float = 1.0
export var max_height: float = 0.1
export var height_curve: Curve
export var noise_period: float = 0.25
export var noise_octaves: int = 3
export (int, 0, 6) var subdivisions: int = 5
export (int, 0, 5) var nav_subdivisions: int = 3
export (int, 0, 6) var water_subdivisions: int = 4

export var land_material: Material
export var water_material: Material

onready var path_debug: DebugDraw = $PathDebug
onready var grid_debug: DebugDraw = $GridDebug

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var nav: AStarNavigation

func _ready():
	assert(nav_subdivisions <= subdivisions, "Navigation subdivisions may not be larger then ground subdivisions")
	
	rng.seed = random_seed
	
	var gnd = _create_ground()
	self.nav = _create_nav(gnd)
	
	var ground: MeshInstance = _add_mesh(gnd.mesh, "Ground")
	ground.material_override = land_material
	
	var water: MeshInstance = _add_mesh(_create_water(), "Water")
	water.material_override = water_material
	
	grid_debug.draw_points(nav, Color.white)


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_SPACE:
			draw_random_path()


func draw_random_path():
	var l = nav.get_point_count()
	var path = nav.get_point_path(int(rand_range(0, l)), int(rand_range(0, l)))
	print(path)
	path_debug.draw_path(path, Color.yellow)


func _add_mesh(mesh: Mesh, name: String) -> MeshInstance:
	var node = MeshInstance.new()
	node.name = name
	node.mesh = mesh
	add_child(node)
	
	return node


func _create_ground() -> IcoSphere.Result:
	var gen = IcoSphere.new(subdivisions, radius, true)
	var result: IcoSphere.Result = gen.create([nav_subdivisions])
	
	_add_noise(result.mesh)
	
	return result


func _create_nav(res: IcoSphere.Result) -> AStarNavigation:
	return AStarNavigation.new(
				res.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX],
				res.subdiv_faces[nav_subdivisions],
				radius)


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
	
	var height_map: HeightMap = HeightMap.new(rng, noise, max_height)
	height_map.create_elevation(m, height_curve, true)


func _draw():
	pass
