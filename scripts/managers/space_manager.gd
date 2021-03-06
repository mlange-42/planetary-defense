class_name SpaceManager

var planet

var sky_nodes: Array
var covered: Array

var coverage: int = 0

var facility_functions: Facilities.FacilityFunctions = Facilities.FacilityFunctions.new()

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
			planet.messages.add_message(node, "%s prospected" % \
					StrUtil.bb_link("%s deposit" % Resources.RES_NAMES[res], node), Consts.MESSAGE_INFO)


func update_coverage():
	var stations = []
	
	var facis = planet.roads.facilities()
	for node in facis:
		var fac = facis[node]
		var cov = facility_functions.calc_coverage(fac.type, planet.planet_data, node)
		if fac is GroundStation and fac.is_supplied and cov > 0:
			stations.append( [planet.planet_data.get_position(node), cov] )
	
	var count: int = 0
	
	for i in range(sky_nodes.size()):
		var vertex: Vector3 = sky_nodes[i]
		
		var cov = false
		for v in stations:
			var angle = deg2rad(v[1])
			if (vertex).angle_to(v[0]) < angle:
				cov = true
				count += 1
				break
		
		covered[i] = cov
	
	# warning-ignore:integer_division
	self.coverage = (100 * count) / sky_nodes.size()

