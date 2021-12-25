extends Spatial

class_name Mouse

signal planet_hovered(point)
signal planet_clicked(point, button)
signal planet_entered(point)
signal planet_exited()

onready var raycast = $RayCast

var camera: Camera

var on_planet = false
var is_drag = false
var buttons_pressed = 0

func _ready():
	camera = get_viewport().get_camera()


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			buttons_pressed += 1
		if not event.pressed:
			buttons_pressed -= 1
			if is_drag:
				is_drag = false
				return
			
			var point = _get_collision_point()
			if point != null:
				emit_signal("planet_clicked", point, event.button_index)
	
	elif event is InputEventMouseMotion:
		if buttons_pressed > 0:
			is_drag = true
			
		var point = _get_collision_point()
		
		if point == null:
			if on_planet:
				emit_signal("planet_exited")
		else:
			if not on_planet:
				emit_signal("planet_entered", point)
			emit_signal("planet_hovered", point)
		
		on_planet = point != null


func _get_collision_point():
	var mouse_pos = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)
	
	raycast.translation = origin
	raycast.cast_to = dir * 100
	raycast.force_raycast_update()
	
	if raycast.get_collider() == null:
		return null
	else:
		return raycast.get_collision_point()
