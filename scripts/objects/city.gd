extends Facility
class_name City

onready var label: CityLabel = $Pole/Sprite3D/Viewport/Label
onready var pole: Spatial = $Pole
onready var sprite: Sprite3D = $Pole/Sprite3D
onready var land_use_mesh: ImmediateGeometry = $LandUse

var cells: Dictionary = {}
var land_use: Dictionary = {}
var facilities: Dictionary = {}
var radius: int = Cities.INITIAL_CITY_RADIUS

var _workers: int = Cities.INITIAL_CITY_POP setget , workers
var _population: int = Cities.INITIAL_CITY_POP

var commodity_weights: Array = [100, 100, 100]
var auto_assign_workers: bool = true


func on_ready(planet_data):
	sprite.texture = $Pole/Sprite3D/Viewport.get_texture()
	sprite.texture.set_flags(Texture.FLAG_FILTER | Texture.FLAG_MIPMAPS)
	
	update_cells(planet_data)


func _process(_delta):
	var cam = get_viewport().get_camera().global_transform.origin
	var dist = global_transform.origin.distance_to(cam)
	if dist < Cities.LABEL_MAX_DIST and dist > Cities.LABEL_MIN_DIST:
		var scale = 1.0 / dist
		pole.scale = Vector3.ONE * (0.1 * dist)
		pole.visible = true
	else:
		pole.visible = false


func population() -> int:
	return _population


func workers() -> int:
	return _workers


func add_workers(num: int):
	_workers += num
	_population += num


func remove_workers(num: int):
	_workers -= num
	_population -= num


func free_workers(num: int):
	_workers += num


func assign_workers(num: int):
	_workers -= num


func save() -> Dictionary:
	var lu = []
	
	for node in land_use:
		lu.append([node, land_use[node]])
	
	var dict = .save()
	
	dict["radius"] = radius
	dict["workers"] = _workers
	dict["commodity_weights"] = commodity_weights
	dict["auto_assign_workers"] = auto_assign_workers
	dict["land_use"] = lu
	
	return dict


func read(dict: Dictionary):
	.read(dict)
	
	radius = dict["radius"] as int
	_workers = dict["workers"] as int
	_population = _workers
	auto_assign_workers = dict["auto_assign_workers"] as bool
	
	var weigths = dict["commodity_weights"]
	for i in range(weigths.size()):
		commodity_weights[i] = weigths[i] as int
	
	for lu in dict["land_use"]:
		land_use[lu[0] as int] = lu[1] as int
		_population += LandUse.LU_WORKERS[lu[1] as int]


func can_build(planet_data, node) -> bool:
	return not planet_data.get_node(node).is_water


func has_landuse_requirements(lu: int) -> bool:
	for req in LandUse.LU_REQUIREMENTS[lu]:
		var found = false
		for n in facilities:
			if facilities[n].type == req:
				found = true
				break
		
		if not found:
			return false
	
	return true


func update_cells(planet_data):
	cells.clear()
	var temp_cells = planet_data.get_in_radius(node_id, radius)
	for c in temp_cells:
		cells[c[0]] = c[1]
	
	update_visuals(planet_data)


func add_facility(node: int, facility: Facility):
	facilities[node] = facility


func update_visuals(planet_data):
	label.set_text("%s (%d/%d)" % [name, workers(), population()])
	
	var flows_food = flows.get(Commodities.COMM_FOOD, [0, 0])
	var demand_food = sinks.get(Commodities.COMM_FOOD, 0)
	
	var flows_prod = flows.get(Commodities.COMM_PRODUCTS, [0, 0])
	var demand_prod = sinks.get(Commodities.COMM_PRODUCTS, 0)
	
	if flows_food[1] < demand_food:
		label.self_modulate = Color.red
	elif flows_prod[1] == 0 && demand_prod > 0:
		label.self_modulate = Color.orangered
	elif flows_prod[1] < demand_prod:
		label.self_modulate = Color.yellow
	else:
		label.self_modulate = Color.white
	
	_draw_cells(planet_data)


func set_label_visible(vis: bool):
	pole.visible = vis


func _draw_cells(planet_data):
	land_use_mesh.clear()
	land_use_mesh.begin(Mesh.PRIMITIVE_POINTS)
	
	land_use_mesh.set_color(Color.white)
	
	for c in cells:
		if cells[c] == radius and not c in land_use:
			var p = planet_data.get_position(c)
			land_use_mesh.set_color(Color.dimgray)
			land_use_mesh.add_vertex(self.to_local(p + 2 * Consts.DRAW_HEIGHT_OFFSET * p.normalized()))
	
	for c in land_use:
		var p = planet_data.get_position(c)
		land_use_mesh.set_color(LandUse.LU_COLORS[land_use[c]])
		land_use_mesh.add_vertex(self.to_local(p + 2 * Consts.DRAW_HEIGHT_OFFSET * p.normalized()))
	
	land_use_mesh.end()
