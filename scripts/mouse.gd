extends Spatial

onready var raycast = $RayCast

func _input(event):
	if event is InputEventMouseMotion:
		var camera = get_viewport().get_camera()
		var mouse_pos = get_viewport().get_mouse_position()
		var origin = camera.project_ray_origin(mouse_pos)
		var dir = camera.project_ray_normal(mouse_pos)
		
		raycast.translation = origin
		raycast.cast_to = dir * 100
		raycast.force_raycast_update()
		
		#if raycast.get_collider() != null:
		#	print(raycast.get_collision_point())
		
