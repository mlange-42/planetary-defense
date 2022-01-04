extends Event
class_name AirAttack

var scene: Spatial
var strength = 3
var hits = []
var misses = []


func save() -> Dictionary:
	var dict = .save()
	
	dict["strength"] = strength
	dict["hits"] = hits
	dict["misses"] = misses
	
	return dict


func read(dict: Dictionary):
	.read(dict)
	
	strength = dict["strength"] as int
	
	var h = dict["hits"]
	for hit in h:
		hits.append(hit as int)
	
	var m = dict["misses"]
	for miss in m:
		misses.append([miss[0] as int, miss[1] as int])


func select_target(planet) -> bool:
	var cities = []
	for node in planet.roads.facilities:
		var fac = planet.roads.facilities[node]
		if fac is City:
			cities.append(node)
	
	if cities.empty():
		return false
	
	node_id = cities[randi() % cities.size()]
	
	return true


func init(planet):
	scene = preload("res://scenes/objects/events/air_attack.tscn").instance()
	planet.add_child(scene)
	
	var node = planet.planet_data.get_node(node_id)
	scene.translation = node.position
	scene.look_at(2 * node.position, Vector3.UP)


func do_effect(planet):
	var defenses = []
	for node in planet.roads.facilities:
		var fac = planet.roads.facilities[node]
		if not fac is Defense:
			continue
		
		var def = fac as Defense
		if not def.is_supplied:
			continue
		
		var inter = def.intercepts
		for type in inter:
			if self is type:
				defenses.append([node, def, inter[type]])
	
	var city = planet.roads.facilities[node_id] as City
	var nodes = city.land_use.keys()
	nodes.shuffle()
	
	hits.clear()
	var kills = 0
	
	for i in range(0, min(strength, nodes.size())):
		var node = nodes[i]
		
		var defs = []
		var prob = 1.0
		for def in defenses:
			if def[1].cells.has(node):
				prob *= 1.0 - def[2]
				defs.append(def[0])
		
		if randf() >= prob:
			misses.append([node, defs[randi() % defs.size()]])
			continue
		
		var lu = city.land_use[node]
		var workers = LandUse.LU_WORKERS[lu]
		
		hits.append(node)
		planet.builder.set_land_use(city, node, LandUse.LU_NONE)
		
		city.remove_workers(workers)
		kills += workers
		
		city.update_visuals(planet.planet_data)
		
	return "Alien air attack at [u]%s[/u], %d killed" % [city.name, kills]


func show_effect(planet):
	_draw_hits(planet)


func delete(planet):
	planet.remove_child(scene)
	scene.queue_free()


func _draw_hits(planet):
	var geom: ImmediateGeometry = scene.get_node("Hits")
	var center = scene.to_local((scene.get_node("Ship") as Spatial).global_transform.origin)
	
	geom.clear()
	geom.begin(Mesh.PRIMITIVE_LINES)
	
	geom.set_color(Color.red)
	
	for node in hits:
		var p = scene.to_local(planet.planet_data.get_position(node))
		geom.add_vertex(center)
		geom.add_vertex(p)
	
	for node_def in misses:
		var p = scene.to_local(planet.planet_data.get_position(node_def[0]))
		var p_def = scene.to_local(planet.planet_data.get_position(node_def[1]))
		var p_inter = center + 0.75 * (p - center)
		
		geom.set_color(Color.magenta)
		geom.add_vertex(center)
		geom.add_vertex(p_inter)
		
		geom.set_color(Color.blue)
		geom.add_vertex(p_def)
		geom.add_vertex(p_inter)
		
	
	geom.end()
