class_name GeoUtil


# Calculate lon/lat vector from _normalized_ xyz
static func xyz_to_lla(xyz: Vector3) -> Vector2:
	var lat = asin(xyz.y)
	var lon = atan2(xyz.z, xyz.x)
	
	return Vector2(rad2deg(lon), rad2deg(lat))


# Calculate xyz vector from lon/lat
static func lla_to_xyz(lla: Vector2) -> Vector3:
	var lon = lla.x
	var lat = lla.y
	var cosLat = cos(deg2rad(lat))
	var sinLat = sin(deg2rad(lat))
	var cosLon = cos(deg2rad(lon))
	var sinLon = sin(deg2rad(lon))
	var x = cosLat * cosLon
	var y = sinLat
	var z = cosLat * sinLon
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
