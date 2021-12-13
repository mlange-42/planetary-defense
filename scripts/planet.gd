extends Spatial

class_name Planet

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
export (int, 2, 48) var water_rings: int = 24
export (int, 4, 96) var water_segments: int = 48
export var smooth: bool = false

export var land_material: Material
export var water_material: Material

onready var path_debug: DebugDraw = $PathDebug
onready var grid_debug: DebugDraw = $GridDebug

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var nav: NavManager

func _ready():
	assert(nav_subdivisions <= subdivisions, "Navigation subdivisions may not be larger then ground subdivisions")
	
	if use_random_seed:
		rng.seed = random_seed
	else:
		rng.randomize()
	
	var gnd: IcoSphere.Result = _create_ground()
	self.nav = _create_nav(gnd)
	
	var ground: MeshInstance = _add_mesh(gnd.mesh, "Ground")
	ground.material_override = land_material
	
	var water: MeshInstance = _add_mesh(_create_water(), "Water")
	water.material_override = water_material
	
	var collision = _create_collision_shape(gnd.mesh, gnd.subdiv_faces[nav_subdivisions])
	add_child(collision)
	
	if not smooth:
		GeoUtil.split_unsmooth(gnd.mesh)
	
	grid_debug.draw_points(nav)


func draw_path(from: int, to: int) -> bool:
	if nav.nav_land.has_point(from) and nav.nav_land.has_point(to):
		var path = nav.nav_land.get_point_path(from, to)
		path_debug.draw_path(path, Color.yellow)
		return true
	
	return false


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


func _create_water() -> Mesh:
	var sphere = UvSphere.new(water_rings, water_segments, radius)
	return sphere.create()


func _create_nav(res: IcoSphere.Result) -> NavManager:
	return NavManager.new(
				res.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX],
				res.subdiv_faces[nav_subdivisions],
				radius)


func _create_collision_shape(mesh: Mesh, indices: PoolIntArray) -> Area:
	var vertices = mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	
	var coll := ConcavePolygonShape.new()
	var faces := PoolVector3Array()
	
	for id in indices:
		faces.append(vertices[id])
	
	coll.set_faces(faces)
	
	var area = Area.new()
	var shape = CollisionShape.new()
	shape.shape = coll
	area.add_child(shape)
	area.name = "Area"
	
	return area

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
