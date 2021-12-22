class_name GeoUtil


# Calculate lon/lat vector (in degrees) from _normalized_ xyz
static func xyz_to_lla(xyz: Vector3) -> Vector2:
	var lat = asin(xyz.y)
	var lon = atan2(xyz.z, xyz.x)
	
	return Vector2(rad2deg(lon), rad2deg(lat))


# Calculate xyz vector from lon/lat (in degrees)
static func lla_to_xyz(lla: Vector2) -> Vector3:
	var lon = lla.x
	var lat = lla.y
	var cos_lat = cos(deg2rad(lat))
	var sin_lat = sin(deg2rad(lat))
	var cos_lon = cos(deg2rad(lon))
	var sin_lon = sin(deg2rad(lon))
	var x = cos_lat * cos_lon
	var y = sin_lat
	var z = cos_lat * sin_lon
	return Vector3(x, y, z)

# Calculate UV coordinates on a _unit_ sphere (i.e. assumes radius 0)
static func calc_sphere_uv(verts: PoolVector3Array) -> PoolVector2Array:
	var uvs := PoolVector2Array()
	uvs.resize(verts.size())
	
	var uv: Vector2
	for i in range(verts.size()):
		uv = xyz_to_lla(verts[i])
		uv.x = (uv.x / 360.0) + 0.5
		uv.y = (uv.y / 180.0) + 0.5
		uvs[i] = uv
	
	return uvs


# Un-smooths a mesh. Results in duplicate vertices and re-odering!
static func split_unsmooth(mesh: Mesh):
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	st.append_from(mesh, 0, Transform.IDENTITY)
	st.generate_normals()
	
	mesh.surface_remove(0)
	st.commit(mesh)
