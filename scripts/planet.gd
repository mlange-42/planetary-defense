extends Spatial

class_name Planet

export var use_random_seed: bool = true
export var random_seed: int = 0
export var radius: float = 1.0

export var max_height: float = 0.1
export var height_step: float = 0.05
export (String, "", "basic", "billow", "hybrid", "fbm", "ridged", "open-simplex", "super-simplex", "perlin") \
		var noise_type: String = ""
export var noise_period: float = 0.5
export var noise_octaves: int = 4
export var noise_seed: int = -1

export var height_curve: Curve

export (String, "", "basic", "billow", "hybrid", "fbm", "ridged", "open-simplex", "super-simplex", "perlin") \
		var climate_noise_type: String = ""
export var climate_noise_period: float = 0.5
export var climate_noise_octaves: int = 3
export var climate_noise_seed: int = -1

export (int, 0, 6) var subdivisions: int = 5
export (int, 2, 48) var water_rings: int = 24
export (int, 4, 96) var water_segments: int = 48
export var smooth: bool = false

export var land_material: Material
export var water_material: Material

onready var facilities: Spatial = $Facilities

onready var road_debug: DebugDraw = $RoadDebug
onready var path_debug: DebugDraw = $PathDebug

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var planet_data = null
var roads: RoadNetwork
var builder: BuildManager
var flow: FlowManager
var cities: CityManager

func _ready():
	
	if use_random_seed:
		rng.seed = random_seed
	else:
		rng.randomize()
	
	if noise_seed < 0:
		noise_seed = rng.randi()
	if climate_noise_seed < 0:
		climate_noise_seed = rng.randi()
	
	var gen = PlanetGenerator.new()
	gen.initialize(
		radius, subdivisions, max_height, height_step, 
		noise_type, noise_period, noise_octaves, noise_seed, height_curve,
		climate_noise_type, climate_noise_period, climate_noise_octaves, climate_noise_seed)
	
	var result = gen.generate()
	
	var consts: Constants = $"/root/GameConstants" as Constants
	
	self.planet_data = result[0]
	self.roads = RoadNetwork.new()
	self.builder = BuildManager.new(consts, roads, planet_data, facilities)
	self.flow = FlowManager.new(roads)
	self.cities = CityManager.new(consts, roads, planet_data)
	
	var ground: MeshInstance = _add_mesh(result[1], "Ground")
	ground.material_override = land_material
	
	var water: MeshInstance = _add_mesh(_create_water(), "Water")
	water.material_override = water_material
	
	var collision = _create_collision(result[2])
	add_child(collision)
	
	if not smooth:
		GeoUtil.split_unsmooth(ground.mesh)
	
	# self.planet_data.to_csv("planet.csv")
	


func calc_point_path(from: int, to: int) -> Array:
	if planet_data.has_point(from, planet_data.NAV_LAND) and planet_data.has_point(to, planet_data.NAV_LAND):
		var path = planet_data.get_point_path(from, to, planet_data.NAV_LAND)
		return path
	
	return []


func calc_id_path(from: int, to: int) -> Array:
	if planet_data.has_point(from, planet_data.NAV_LAND) and planet_data.has_point(to, planet_data.NAV_LAND):
		var path = planet_data.get_id_path(from, to, planet_data.NAV_LAND)
		return path
	
	return []


func draw_path(from: int, to: int) -> bool:
	var path = calc_point_path(from, to)
	if path.size() > 0:
		path_debug.draw_path(path, Color.yellow)
		return true
	
	path_debug.clear()
	return false


func add_road(from: int, to: int):
	var path = calc_id_path(from, to)
	if builder.add_road(path):
		_redraw_roads()


func get_facility(id: int):
	return roads.facilities.get(id)


func _redraw_roads():
	road_debug.draw_roads(planet_data, roads, Color(0.02, 0.02, 0.02), Color.red)


func add_facility(type: String, location: int, name: String):
	return builder.add_facility(type, location, name)


func clear_path():
	path_debug.draw_path([], Color.yellow)


func _add_mesh(mesh: Mesh, name: String) -> GeometryInstance:
	var node = MeshInstance.new()
	node.mesh = mesh
	
	return _add_node(node, name)


func _add_node(node: GeometryInstance, name: String) -> GeometryInstance:
	node.name = name
	add_child(node)
	return node


func _create_water() -> Mesh:
	var sphere = UvSphere.new(water_rings, water_segments, radius + 0.95 * height_step)
	return sphere.create()


func _create_collision(shape: ConcavePolygonShape) -> Area:
	var area = Area.new()
	var shp = CollisionShape.new()
	shp.shape = shape
	area.add_child(shp)
	area.name = "Area"
	
	return area


func next_turn():
	cities.pre_update()
	flow.solve()
	cities.post_update()
	_redraw_roads()
