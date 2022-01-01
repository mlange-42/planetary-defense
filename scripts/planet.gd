extends Spatial

class_name Planet

signal budget_changed(taxes)

var save_name: String = "default"

export var use_random_seed: bool = false
export var random_seed: int = 0
export var radius: float = 10.0

export var max_height: float = 1.0
export var height_step: float = 0.025
export (String, "", "basic", "billow", "hybrid", "fbm", "ridged", "open-simplex", "super-simplex", "perlin") \
		var noise_type: String = "fbm"
export var noise_period: float = 0.7
export var noise_octaves: int = 5
export var noise_seed: int = -1

export var height_curve: Curve = PlanetSettings.HEIGHT_CURVES["normal"]
export var temperature_curve: Curve = PlanetSettings.TEMPERATURE_CURVES["normal"]
export var precipitation_curve: Curve = PlanetSettings.PRECIPITATION_CURVES["normal"]

export (String, "", "basic", "billow", "hybrid", "fbm", "ridged", "open-simplex", "super-simplex", "perlin") \
		var climate_noise_type: String = "fbm"
export var climate_noise_period: float = 0.8
export var climate_noise_octaves: int = 3
export var climate_noise_seed: int = -1

export (int, 0, 7) var subdivisions: int = 6
export (int, 2, 48) var water_rings: int = 48
export (int, 4, 96) var water_segments: int = 96
export var smooth: bool = false
export var atlas_size: int = 4
export var atlas_margin: float = 32.0 / 1024.0

export var land_material: Material = preload("res://assets/materials/vegetation.tres")
export var water_material: Material = preload("res://assets/materials/water.tres")

onready var facilities: Spatial

onready var road_debug: DebugDraw
onready var path_debug: DebugDraw
onready var flows_graphs: FlowGraphs

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var planet_data = null
var roads: RoadNetwork
var builder: BuildManager
var flow: FlowManager
var cities: CityManager
var taxes: TaxManager

# Array of Dictionaries to override parameters
func _init(params: Array):
	for par in params:
		for key in par:
			self.set(key, par[key])

func _ready():
	var material = preload("res://assets/materials/unlit_vertex_color.tres")
	
	facilities = Spatial.new()
	add_child(facilities)
	
	road_debug = DebugDraw.new()
	road_debug.material_override = material
	road_debug.set_layer_mask_bit(Constants.LAYER_BASE, false)
	road_debug.set_layer_mask_bit(Constants.LAYER_ROADS, true)
	add_child(road_debug)
	
	path_debug = DebugDraw.new()
	path_debug.material_override = material
	add_child(path_debug)
	
	flows_graphs = FlowGraphs.new()
	flows_graphs.material_override = material
	add_child(flows_graphs)
	
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
		climate_noise_type, climate_noise_period, climate_noise_octaves, climate_noise_seed,
		temperature_curve, precipitation_curve, atlas_size, atlas_margin)
	
	var result = gen.from_csv(planet_file) if load_planet else gen.generate()
	
	self.planet_data = result[0]
	radius = self.planet_data.get_radius()
	
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
		self.taxes = TaxManager.new()
		self.builder = BuildManager.new(consts, roads, planet_data, taxes, facilities)
		self.flow = FlowManager.new(roads)
		self.cities = CityManager.new(consts, roads, planet_data)
		
		if not load_planet:
			FileUtil.create_user_dir(Constants.SAVEGAME_DIR)
			self.planet_data.to_csv(planet_file)
	


func init():
	emit_budget()


func emit_budget():
	emit_signal("budget_changed", taxes)


func save_game():
	FileUtil.create_user_dir(Constants.SAVEGAME_DIR)
	
	var file = File.new()
	
	if file.open(FileUtil.save_path(save_name, FileUtil.GAME_EXTENSION), File.WRITE) != 0:
		print("Error opening file")
		return
	
	var roads_json = to_json(roads.save())
	file.store_line(roads_json)
	
	var taxes_json = to_json(taxes.save())
	file.store_line(taxes_json)
	
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
	
	var consts: Constants = $"/root/GameConstants" as Constants
	
	var roads_json = file.get_line()
	self.roads = RoadNetwork.new()
	self.roads.read(parse_json(roads_json))
	
	var taxes_json = file.get_line()
	self.taxes = TaxManager.new()
	self.taxes.read(parse_json(taxes_json))
	
	self.builder = BuildManager.new(consts, roads, planet_data, taxes, facilities)
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
		emit_budget()


func remove_road(from: int, to: int):
	var path = calc_id_path(from, to)
	if builder.remove_road(path):
		_redraw_roads()


func get_facility(id: int):
	return roads.facilities.get(id)


func _redraw_roads():
	road_debug.draw_roads(planet_data, roads, Color(0.02, 0.02, 0.02), Color.red)


func draw_flows(commodity: String, color1: Color, color2: Color) -> int:
	flows_graphs.set_colors(color1, color2)
	return flows_graphs.draw_flows(planet_data, roads.pair_flows, commodity)


func add_facility(type: String, location: int, name: String):
	var fac_err = builder.add_facility(type, location, name)
	if fac_err[0] != null:
		emit_budget()
	return fac_err


func clear_path():
	path_debug.clear_all()


func clear_flows():
	flows_graphs.clear_all()


func _add_mesh(mesh: Mesh, name: String) -> GeometryInstance:
	var node = MeshInstance.new()
	node.mesh = mesh
	
	return _add_node(node, name)


func _add_node(node: GeometryInstance, name: String) -> GeometryInstance:
	node.name = name
	add_child(node)
	return node


func _create_water() -> Mesh:
	var sphere = UvSphere.new(water_rings, water_segments, radius + 0.8 * height_step)
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
	
	taxes.earn_taxes(roads.total_flows)
	taxes.road_transport_costs(roads.edges)
	
	_redraw_roads()
	
	emit_budget()
