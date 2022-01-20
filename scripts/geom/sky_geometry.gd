extends MeshInstance
class_name SkyGeometry

var planet
var radius


# warning-ignore:shadowed_variable
func _init(planet, subdivisions: int):
	self.planet = planet
	
	self.radius = self.planet.planet_data.get_radius() + self.planet.planet_data.get_max_elevation()
	
	var sky_gen = IcoSphere.new()
	self.mesh = sky_gen.create_ico_sphere_mesh(self.radius, subdivisions, false)
	self.material_override = preload("res://assets/materials/indicators/sky_coverage.tres")


func _process(_delta):
	var cam = get_viewport().get_camera().global_transform.origin
	var dist = global_transform.origin.distance_to(cam)
	if dist > planet.radius * 4:
		visible = true
	else:
		visible = false


func draw_coverage():
	var col1 = Color(1.0, 1.0, 1.0, 0.4)
	var col2 = Color(1.0, 1.0, 1.0, 0.0)
	
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(self.mesh, 0)
	
	var covered = planet.space.covered
	for i in range(mdt.get_vertex_count()):
		mdt.set_vertex_color(i, col2 if covered[i] else col1)
	
	mesh.surface_remove(0)
	mdt.commit_to_surface(mesh)
	self.mesh = mesh
