class_name SpaceManager

var planet

var sky_nodes: Array
var covered: Array

var coverage: int = 0


# warning-ignore:shadowed_variable
func _init(planet, mesh: ArrayMesh):
	self.planet = planet
	
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	
	sky_nodes = []
	covered = []
	
	for i in mdt.get_vertex_count():
		sky_nodes.append(mdt.get_vertex(i))
		covered.append(false)


func update_turn():
	update_coverage()
	
	var prop = Resources.MAX_REVEAL_PROPORTION * coverage / 100.0
	if prop > 0:
		var revealed = planet.resources.reveal_random_resources(prop, 1)
		for node in revealed:
			var res = planet.resources.resources[node][0]
			planet.messages.add_message(node, "%s deposit prospected" % [Resources.RES_NAMES[res]], Consts.MESSAGE_INFO)


func update_coverage():
	var stations = []
	
	var facis = planet.roads.facilities()
	for node in facis:
		var fac = facis[node]
		if fac is GroundStation and fac.is_supplied:
			stations.append( planet.planet_data.get_position(node) )
	
	var count: int = 0
	
	var angle = deg2rad(45)
	
	for i in range(sky_nodes.size()):
		var vertex: Vector3 = sky_nodes[i]
		
		var cov = false
		for v in stations:
			if (vertex).angle_to(v) < angle:
				cov = true
				count += 1
				break
		
		covered[i] = cov
	
	# warning-ignore:integer_division
	self.coverage = (100 * count) / sky_nodes.size()

