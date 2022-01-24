extends Spatial

class_name Planet

signal budget_changed(taxes)

var save_name: String = "default"

export var use_random_seed: bool = false
export var random_seed: int = 0
export var radius: float = 10.0

export var max_height: float = 1.0
export var height_step: float = 0.016
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
export (int, 0, 4) var sky_subdivisions: int = 4
export var smooth: bool = false
export var atlas_size: Array = [4, 4]
export var atlas_margin: Array = [32.0 / 2048.0, 32.0 / 1024.0]

export var min_slope_cliffs: int = Network.TYPE_MAX_SLOPE[Network.T_ROAD]
export var min_elevation_cliffs: int = int(Consts.ELEVATION_SCALE * 0.6)

export var resource_abundance: int = PlanetSettings.RESOURCE_ABUNDANCE["normal"]

export var land_material: Material = Materials.VEGETATION
export var water_material: Material = Materials.WATER

var facilities: Spatial

var network_geometries: Dictionary = {}
var sky_geometry: SkyGeometry

var path_debug: DebugDraw
var resource_debug: DebugDraw
var flows_graphs: FlowGraphs

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var planet_data = null

var stats: StatsManager
var roads: NetworkManager
var builder: BuildManager
var flow: FlowManager
var cities: CityManager
var taxes: TaxManager
var resources: ResourceManager
var messages: MessageManager
var story: StoryManager
var space: SpaceManager

# Array of Dictionaries to override parameters
func _init(params: Array):
	for par in params:
		for key in par:
			self.set(key, par[key])

func _ready():
	var material = preload("res://assets/materials/vertex_color.tres")
	var flow_material = preload("res://assets/materials/unlit_vertex_color.tres")
	
	var material_resources = preload("res://assets/materials/unlit_vertex_color_large.tres")
	
	facilities = Spatial.new()
	add_child(facilities)
	
	for tp in Network.TYPE_MATERIALS:
		var mat = Network.TYPE_MATERIALS[tp]
		var road_geometry = RoadGeometry.new(Network.TYPE_DRAW_WIDTH[tp])
		road_geometry.material_override = mat
		road_geometry.set_layer_mask_bit(Consts.LAYER_BASE, false)
		road_geometry.set_layer_mask_bit(Consts.LAYER_ROADS, true)
		add_child(road_geometry)
		
		network_geometries[tp] = road_geometry
	
	path_debug = DebugDraw.new()
	path_debug.material_override = material
	add_child(path_debug)
	
	resource_debug = DebugDraw.new()
	resource_debug.material_override = material_resources
	resource_debug.set_layer_mask_bit(Consts.LAYER_BASE, false)
	resource_debug.set_layer_mask_bit(Consts.LAYER_RESOURCES, true)
	add_child(resource_debug)
	
	flows_graphs = FlowGraphs.new()
	flows_graphs.material_override = flow_material
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
		temperature_curve, precipitation_curve, atlas_size, atlas_margin,
		Consts.ELEVATION_CONTOUR_STEP / float(Consts.ELEVATION_SCALE),
		min_slope_cliffs / float(Consts.ELEVATION_SCALE),
		min_elevation_cliffs / float(Consts.ELEVATION_SCALE))
	
	var result = gen.from_csv(planet_file) if load_planet else gen.generate()
	
	self.planet_data = result[0]
	self.planet_data.set_network(FlowNetwork.new())
	radius = self.planet_data.get_radius()
	
	var ground: MeshInstance = _add_mesh(result[1], "Ground")
	ground.material_override = land_material
	
	var water: MeshInstance = _add_mesh(_create_water(), "Water")
	water.material_override = water_material
	
	var collision = _create_collision(result[2])
	add_child(collision)
	
	sky_geometry = SkyGeometry.new(self, sky_subdivisions)
	add_child(sky_geometry)
	
	if not smooth:
		GeoUtil.split_unsmooth(ground.mesh)
	
	if load_planet and FileUtil.save_path_exists(save_name, FileUtil.GAME_EXTENSION):
		load_game()
	else:
		var consts: LandUse = $"/root/VegetationLandUse" as LandUse
		self.stats = StatsManager.new()
		self.messages = MessageManager.new()
		self.story = StoryManager.new(self)
		self.roads = NetworkManager.new(planet_data)
		self.taxes = TaxManager.new()
		self.resources = ResourceManager.new(planet_data, resource_abundance)
		self.builder = BuildManager.new(consts, self, facilities)
		self.flow = FlowManager.new(roads)
		self.cities = CityManager.new(consts, self)
		self.space = SpaceManager.new(self, sky_geometry.mesh)
		
		self.resources.generate_resources()
		self.space.update_coverage()
		_redraw_resources()
		_redraw_sky()
		
		if not load_planet:
			FileUtil.create_user_dir(Consts.SAVEGAME_DIR)
			self.planet_data.to_csv(planet_file)
			self.save_game()


func init():
	emit_budget()


func emit_budget():
	emit_signal("budget_changed", taxes)


func save_game():
	FileUtil.create_user_dir(Consts.SAVEGAME_DIR)
	
	var file = File.new()
	
	if file.open(FileUtil.save_path(save_name, FileUtil.GAME_EXTENSION), File.WRITE) != 0:
		print("Error opening file")
		return
	
	var stats_json = to_json(stats.save())
	file.store_line(stats_json)
	
	var msg_json = to_json(messages.save())
	file.store_line(msg_json)
	
	var story_json = to_json(story.save())
	file.store_line(story_json)
	
	var roads_json = to_json(roads.save())
	file.store_line(roads_json)
	
	var taxes_json = to_json(taxes.save())
	file.store_line(taxes_json)
	
	var resources_json = to_json(resources.save())
	file.store_line(resources_json)
	
	for node in roads.facilities():
		var facility = roads.get_facility(node)
		
		var city_json = to_json(facility.save())
		file.store_line(city_json)
	
	file.close()


func load_game():
	
	var file := File.new()
	if file.open(FileUtil.save_path(save_name, FileUtil.GAME_EXTENSION), File.READ) != 0:
		print("Error opening file")
		return
	
	var consts: LandUse = $"/root/VegetationLandUse" as LandUse
	
	var stats_json = file.get_line()
	self.stats = StatsManager.new()
	self.stats.read(parse_json(stats_json))
	
	var msg_json = file.get_line()
	self.messages = MessageManager.new()
	self.messages.read(parse_json(msg_json))
	
	var story_json = file.get_line()
	self.story = StoryManager.new(self)
	self.story.read(parse_json(story_json))
	
	var roads_json = file.get_line()
	self.roads = NetworkManager.new(planet_data)
	self.roads.read(parse_json(roads_json))
	
	var taxes_json = file.get_line()
	self.taxes = TaxManager.new()
	self.taxes.read(parse_json(taxes_json))
	
	var resources_json = file.get_line()
	self.resources = ResourceManager.new(planet_data, resource_abundance)
	self.resources.read(parse_json(resources_json))
	
	self.builder = BuildManager.new(consts, self, facilities)
	self.flow = FlowManager.new(roads)
	self.cities = CityManager.new(consts, self)
	
	
	self.space = SpaceManager.new(self, sky_geometry.mesh)
	
	
	while not file.eof_reached():
		var line: String = file.get_line()
		
		if line.empty():
			continue
		
		var fac_json = parse_json(line)
		var facility: Facility = load(Facilities.FACILITY_SCENES[fac_json["type"]]).instance()
		facility.init(fac_json["node_id"] as int, self, fac_json["type"])
		facility.read(fac_json)
		
		builder.add_facility_scene(facility, facility.name)
		
		if facility is City:
			for node in facility.land_use:
				planet_data.set_occupied(node, true)
	
	var fac = roads.facilities()
	
	for node in fac:
		var facility = fac[node]
		if facility.city_node_id >= 0:
			roads.get_facility(facility.city_node_id).add_facility(node, facility)
	
	file.close()
	
	self.space.update_coverage()
	
	_redraw_roads(-1)
	_redraw_resources()
	_redraw_sky()


func calc_point_path(from: int, to: int, type: int) -> Array:
	var nav = Network.MODE_NAV[Network.TYPE_MODES[type]]
	var path = planet_data.get_point_path(from, to, nav, Network.TYPE_MAX_SLOPE[type] / float(Consts.ELEVATION_SCALE))
	return path


func calc_id_path(from: int, to: int, type: int) -> Array:
	var nav = Network.MODE_NAV[Network.TYPE_MODES[type]]
	var path = planet_data.get_id_path(from, to, nav, Network.TYPE_MAX_SLOPE[type] / float(Consts.ELEVATION_SCALE))
	return path


func draw_path(from: int, to: int, type: int, erase: bool, max_length: int) -> Array:
	var path = calc_point_path(from, to, type)
	if path.size() > 0:
		var col = Color.magenta if erase else Color.blue
		path_debug.draw_path(path, max_length, col, Color.red)
	else:
		path_debug.clear()
	return path


func add_road(from: int, to: int, type: int):
	var path = calc_id_path(from, to, type)
	var changed = {}
	var err = builder.add_road(path, type, changed)
	
	for c in changed:
		_redraw_roads(c)
	emit_budget()
	
	return err


func remove_road(from: int, to: int, type: int):
	var mode = Network.TYPE_MODES[type]
	var path = calc_id_path(from, to, type)
	if builder.remove_road(path, mode):
		_redraw_roads(type)


func get_facility(id: int):
	return roads.get_facility(id)


func set_traffic_commodity(comm: int):
	for tp in network_geometries:
		(network_geometries[tp] as RoadGeometry).material_override.set_shader_param("channel", comm)


func _redraw_roads(type: int):
	if type < 0:
		for tp in network_geometries:
			network_geometries[tp].draw_type(planet_data, roads, tp)
	else:
		network_geometries[type].draw_type(planet_data, roads, type)


func _redraw_resources():
	resource_debug.draw_resources(planet_data, resources)


func _redraw_sky():
	sky_geometry.draw_coverage()


func draw_flows(commodity: int, color1: Color, color2: Color) -> int:
	flows_graphs.set_colors(color1, color2)
	return flows_graphs.draw_flows(planet_data, roads.pair_flows, commodity)


func add_facility(type: String, location: int, name: String, owner):
	var fac_err = builder.add_facility(type, location, name, owner)
	if fac_err[0] != null:
		emit_budget()
	return fac_err


func grow_city(city: City):
	var err = builder.grow_city(city)
	if err == null:
		emit_budget()
	return err


func clear_path():
	path_debug.clear_all()


func clear_flows():
	flows_graphs.clear_all()

func show_flows(vis: bool):
	flows_graphs.visible = vis


func _add_mesh(mesh: Mesh, name: String) -> GeometryInstance:
	var node = MeshInstance.new()
	node.mesh = mesh
	
	return _add_node(node, name)


func _add_node(node: GeometryInstance, name: String) -> GeometryInstance:
	node.name = name
	add_child(node)
	return node


func _create_water() -> Mesh:
	var sphere = UvSphere.new(water_rings, water_segments, radius)
	return sphere.create()


func _create_collision(shape: ConcavePolygonShape) -> Area:
	var area = Area.new()
	var shp = CollisionShape.new()
	shp.shape = shape
	area.add_child(shp)
	area.name = "Area"
	
	return area


func next_turn():
	messages.clear_messages()
	
	story.update_turn()
	
	cities.pre_update()
	flow.solve()
	cities.post_update()
	cities.assign_workers(builder)
	
	taxes.earn_taxes(roads.total_flows)
	taxes.pay_costs(roads.facilities(), roads)
	
	stats.update_data(self)
	
	space.update_turn()
	stats.update_turn()
	
	_redraw_roads(-1)
	_redraw_resources()
	_redraw_sky()
	
	emit_budget()
