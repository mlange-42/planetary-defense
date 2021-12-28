extends Spatial

class_name Planet

var save_name: String = "default"

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
onready var flows_debug: DebugDraw = $FlowsDebug

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var planet_data = null
var roads: RoadNetwork
var builder: BuildManager
var flow: FlowManager
var cities: CityManager

func _ready():
	var planet_file = FileUtil.save_path(save_name, FileUtil.PLANET_EXTENSION)
	var load_planet = FileUtil.save_path_exists(save_name, FileUtil.PLANET_EXTENSION)
	
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
	
	var result = gen.from_csv(planet_file) if load_planet else gen.generate()
	
	self.planet_data = result[0]
	
	var ground: MeshInstance = _add_mesh(result[1], "Ground")
	ground.material_override = land_material
	
	var water: MeshInstance = _add_mesh(_create_water(), "Water")
	water.material_override = water_material
	
	var collision = _create_collision(result[2])
	add_child(collision)
	
	if not smooth:
		GeoUtil.split_unsmooth(ground.mesh)
	
	if load_planet and FileUtil.save_path_exists(save_name, FileUtil.GAME_EXTENSION):
		load_game()
	else:
		var consts: Constants = $"/root/GameConstants" as Constants
		self.roads = RoadNetwork.new()
		self.builder = BuildManager.new(consts, roads, planet_data, facilities)
		self.flow = FlowManager.new(roads)
		self.cities = CityManager.new(consts, roads, planet_data)
		
		if not load_planet:
			self.planet_data.to_csv(planet_file)


func save_game():
	var file = File.new()
	if file.open(FileUtil.save_path(save_name, FileUtil.GAME_EXTENSION), File.WRITE) != 0:
		print("Error opening file")
		return
	
	var roads_json = to_json(roads.save())
	file.store_line(roads_json)
	
	for node in roads.facilities:
		var facility = roads.facilities[node]
		
		var city_json = to_json(facility.save())
		file.store_line(city_json)
	
	file.close()


func load_game():	
	var file := File.new()
	if file.open(FileUtil.save_path(save_name, FileUtil.GAME_EXTENSION), File.READ) != 0:
		print("Error opening file")
		return
	
	var roads_json = file.get_line()
	self.roads = RoadNetwork.new()
	self.roads.read(parse_json(roads_json))
	
	var consts: Constants = $"/root/GameConstants" as Constants
	self.builder = BuildManager.new(consts, roads, planet_data, facilities)
	self.flow = FlowManager.new(roads)
	self.cities = CityManager.new(consts, roads, planet_data)
	
	while not file.eof_reached():
		var line: String = file.get_line()
		
		if line.empty():
			continue
		
		var fac_json = parse_json(line)
		var facility: Facility = load(Constants.FACILITY_SCENES[fac_json["type"]]).instance()
		facility.init(fac_json["node_id"] as int, planet_data)
		facility.read(fac_json)
		
		builder.add_facility_scene(facility, facility.name)
		
		if facility is City:
			for node in facility.land_use:
				planet_data.set_occupied(node, true)
	
	for node in roads.facilities:
		var facility = roads.facilities[node]
		if facility.city_node_id >= 0:
			roads.facilities[facility.city_node_id].add_facility(node, facility)
	
	file.close()
	
	_redraw_roads()


func calc_point_path(from: int, to: int) -> Array:
	var mode = planet_data.NAV_WATER if planet_data.get_node(from).is_water and planet_data.get_node(to).is_water \
				else planet_data.NAV_LAND
	
	var path = planet_data.get_point_path(from, to, mode)
	return path


func calc_id_path(from: int, to: int) -> Array:
	var mode = planet_data.NAV_WATER if planet_data.get_node(from).is_water and planet_data.get_node(to).is_water \
				else planet_data.NAV_LAND
	
	var path = planet_data.get_id_path(from, to, mode)
	return path


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


func remove_road(from: int, to: int):
	var path = calc_id_path(from, to)
	if builder.remove_road(path):
		_redraw_roads()


func get_facility(id: int):
	return roads.facilities.get(id)


func _redraw_roads():
	road_debug.draw_roads(planet_data, roads, Color(0.02, 0.02, 0.02), Color.red)


func draw_flows(commodity: String):
	flows_debug.draw_flows(planet_data, roads.pair_flows, commodity, Color.white, Color.purple)


func add_facility(type: String, location: int, name: String):
	return builder.add_facility(type, location, name)


func clear_path():
	path_debug.clear_all()


func clear_flows():
	flows_debug.clear_all()


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
	cities.assign_workers(builder)
	_redraw_roads()
