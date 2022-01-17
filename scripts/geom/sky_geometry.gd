extends MeshInstance
class_name SkyGeometry

var planet
var coverage: int = 0


# warning-ignore:shadowed_variable
func _init(planet):
	self.planet = planet
	
	var rad = self.planet.planet_data.get_radius() + self.planet.planet_data.get_max_elevation()
	
	var sky_gen = IcoSphere.new()
	self.mesh = sky_gen.create_ico_sphere_mesh(rad, 3, false)
	self.material_override = preload("res://assets/materials/indicators/sky_coverage.tres")


func _process(_delta):
	var cam = get_viewport().get_camera().global_transform.origin
	var dist = global_transform.origin.distance_to(cam)
	if dist > planet.radius * 4:
		visible = true
	else:
		visible = false


func update_coverage():
	var stations = []
	
	var facis = planet.roads.facilities()
	for node in facis:
		var fac = facis[node]
		if fac is PowerPlant:
			stations.append( planet.planet_data.get_position(node) )
	
	var col1 = Color(1.0, 1.0, 1.0, 0.4)
	var col2 = Color(1.0, 1.0, 1.0, 0.0)
	
	var count: int = 0
	
	var angle = deg2rad(45)
	
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(self.mesh, 0)
	for i in range(mdt.get_vertex_count()):
		var vertex: Vector3 = mdt.get_vertex(i)
		
		var covered = false
		for v in stations:
			if (vertex).angle_to(v) < angle:
				covered = true
				count += 1
				break
		
		mdt.set_vertex_color(i, col2 if covered else col1)
	
	self.coverage = (100 * count) / mdt.get_vertex_count()
	
	mesh.surface_remove(0)
	mdt.commit_to_surface(mesh)
	self.mesh = mesh

