extends ImmediateGeometry



func _ready():
	var planet_gen = preload("res://scripts/native/planet_generator.gdns").new()
	
	var data = planet_gen.generate(10.0, 5)
	
	#for i in data.get_node_count():
	#	print(data.get_neighbors(i))
	
	var mesh: ArrayMesh = data.get_mesh()
	
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
