class_name SpaceManager


var sky_nodes: Array
var covered: Array

var coverage: int = 0


func _init(mesh: ArrayMesh):
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	
	sky_nodes = []
	covered = []
	
	for i in mdt.get_vertex_count():
		sky_nodes.append(mdt.get_vertex(i))
		covered.append(false)


func update_coverage(planet):
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

