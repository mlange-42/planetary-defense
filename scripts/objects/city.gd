extends Facility
class_name City

onready var label: CityLabel = $Pole/Sprite3D/Viewport/Label
onready var pole: Spatial = $Pole
onready var land_use_mesh: ImmediateGeometry = $LandUse

var cells: Dictionary = {}
var land_use: Dictionary = {}
var facilities: Dictionary = {}
var radius: int = Consts.INITIAL_CITY_RADIUS
var workers: int = Consts.INITIAL_CITY_POP

var commodity_weights: Array = [100, 100, 100]
var auto_assign_workers: bool = true


func init(node: int, planet_data):
	.init(node, planet_data)
	type = Facilities.FAC_CITY


func on_ready(planet_data):
	var sprite = $Pole/Sprite3D
	
	sprite.texture = $Pole/Sprite3D/Viewport.get_texture()
	sprite.texture.set_flags(Texture.FLAG_FILTER | Texture.FLAG_MIPMAPS)
	
	update_cells(planet_data)


func save() -> Dictionary:
	var lu = []
	
	for node in land_use:
		lu.append([node, land_use[node]])
	
	var conv = []
	for key in conversions:
		var c = conversions[key]
		conv.append([key, c])
	
	var dict = {
		"type": type,
		"name": name,
		"node_id": node_id,
		"radius": radius,
		"workers": workers,
		"commodity_weights": commodity_weights,
		"auto_assign_workers": auto_assign_workers,
		"land_use": lu,
		"sources": sources,
		"sinks": sinks,
		"conversions": conv,
		"flows": flows,
	}
	
	return dict


func read(dict: Dictionary):
	name = dict["name"]
	node_id = dict["node_id"] as int
	radius = dict["radius"] as int
	workers = dict["workers"] as int
	auto_assign_workers = dict["auto_assign_workers"] as bool
	
	var weigths = dict["commodity_weights"]
	for i in range(weigths.size()):
		commodity_weights[i] = weigths[i] as int
	
	for lu in dict["land_use"]:
		land_use[lu[0] as int] = lu[1] as int
	
	var fl = dict["flows"]
	for comm in fl:
		var f = fl[comm]
		flows[comm] = [f[0] as int, f[1] as int]
		
	var so = dict["sources"]
	for comm in so:
		sources[comm] = so[comm] as int
		
	var si = dict["sinks"]
	for comm in si:
		sinks[comm] = si[comm] as int
		
	var co = dict["conversions"]
	for comm in co:
		var c = comm[1]
		conversions[comm[0]] = [c[0] as int, c[1] as int]


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
	label.set_text("%s (%d)" % [name, workers])
	
	var flows_food = flows.get(Commodities.COMM_FOOD, [0, 0])
	var demand_food = sinks.get(Commodities.COMM_FOOD, 0)
	
	var flows_prod = flows.get(Commodities.COMM_PRODUCTS, [0, 0])
	var demand_prod = sinks.get(Commodities.COMM_PRODUCTS, 0)
	
	if flows_food[1] < demand_food:
		label.self_modulate = Color.red
	elif flows_prod[1] == 0:
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
