extends ImmediateGeometry



func _ready():
	var ico_gen = preload("res://scripts/native/ico_sphere.gdns").new()
	var result = ico_gen.create_ico_sphere(10.0, 2)
	var vertices = result[0]
	var indices = result[1]
	
	var mesh: ArrayMesh = ico_gen.to_mesh(vertices, indices)
	
	var inst := MeshInstance.new()
	inst.mesh = mesh
	
	add_child(inst)
	
#	print(mesh.surface_get_arrays(0)[Mesh.ARRAY_INDEX])
#
#	begin(Mesh.PRIMITIVE_TRIANGLES)
#	set_color(Color.white)
#
#	for idx in indices:
#		for i in range(3):
#			var v = vertices[idx[i]]
#			set_normal(Vector3(v[0], v[1], v[2]))
#			add_vertex(Vector3(v[0], v[1], v[2]))
#
#
#	end()
