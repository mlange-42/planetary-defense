extends Spatial

export var use_random_seed: bool = true
export var random_seed: int = 0
export var radius: float = 1.0
export var max_height: float = 0.1
export var height_curve: Curve
export var height_step: float = 0.005
export var noise_period: float = 0.25
export var noise_octaves: int = 3
export (int, 0, 6) var subdivisions: int = 5
export (int, 0, 5) var nav_subdivisions: int = 3
export (int, 6, 48) var water_rings: int = 24
export (int, 6, 96) var water_segments: int = 48

export var land_material: Material
export var water_material: Material

onready var path_debug: DebugDraw = $PathDebug
onready var grid_debug: DebugDraw = $GridDebug

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var nav: AStarNavigation

func _ready():
	assert(nav_subdivisions <= subdivisions, "Navigation subdivisions may not be larger then ground subdivisions")
	
	if use_random_seed:
		rng.seed = random_seed
	else:
		rng.randomize()
	
	var gnd = _create_ground()
	self.nav = _create_nav(gnd)
	
	var ground: MeshInstance = _add_mesh(gnd.mesh, "Ground")
	ground.material_override = land_material
	
	var water: GeometryInstance = _add_node(_create_water(), "Water")
	water.material_override = water_material
	
	grid_debug.draw_points(nav, Color.white)


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_SPACE:
			draw_random_path()


func draw_random_path():
	var indices = nav.get_points()
	var l = indices.size()
	
	var path = []
	while path.empty():
		path = nav.get_point_path(
					indices[rng.randi_range(0, l-1)], 
					indices[rng.randi_range(0, l-1)])
		
	path_debug.draw_path(path, Color.yellow)


func _add_mesh(mesh: Mesh, name: String) -> GeometryInstance:
	var node = MeshInstance.new()
	node.mesh = mesh
	
	return _add_node(node, name)


func _add_node(node: GeometryInstance, name: String) -> GeometryInstance:
	node.name = name
	add_child(node)
	return node


func _create_ground() -> IcoSphere.Result:
	var gen = IcoSphere.new(subdivisions, radius, true)
	var result: IcoSphere.Result = gen.create([nav_subdivisions])
	
	_add_noise(result.mesh)
	
	return result


func _create_water() -> CSGSphere:
	var sphere = CSGSphere.new()
	sphere.radius = radius
	sphere.rings = water_rings
	sphere.radial_segments = water_segments
	return sphere


func _create_nav(res: IcoSphere.Result) -> AStarNavigation:
	return AStarNavigation.new(
				res.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX],
				res.subdiv_faces[nav_subdivisions],
				radius)


func _add_noise(m: Mesh):
	var noise := OpenSimplexNoise.new()
	noise.seed = rng.randi()
	noise.octaves = noise_octaves
	noise.period = noise_period * radius
	noise.persistence = 0.5
	
	var height_map: HeightMap = HeightMap.new(noise, max_height, height_step)
	height_map.create_elevation(m, height_curve, true)


func _draw():
	pass
