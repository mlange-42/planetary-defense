extends Spatial
class_name CameraControl

export var planet_radius: float = 10.0
export var horizontal_sensitivity: float = 0.002
export var vertical_sensitivity: float = 0.002
export var zoom_increment: float = 0.1
export var lerp_speed: float = 10

export var angle_curve: Curve

onready var arm: Spatial = $Arm
onready var arm2: Spatial = $Arm/Arm2
onready var camera: Camera = $Arm/Arm2/Camera

var dragging: bool = false
var zoom_target: float
var rotation_x_target: float
var rotation_y_target: float

var min_height: float
var max_height: float


func init():
	arm2.translation.z = planet_radius
	
	min_height = 1.2
	max_height = 3 * planet_radius
	
	zoom_target = camera.translation.z
	rotation_x_target = arm.rotation.x
	rotation_y_target = rotation.y


func _unhandled_input(event) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT:
			dragging = event.pressed
		elif event.button_index == BUTTON_WHEEL_UP:
			zoom_target = clamp(zoom_target * (1.0 + zoom_increment), min_height, max_height)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			zoom_target = clamp(zoom_target / (1.0 + zoom_increment), min_height, max_height)
	
	var sens = camera.translation.z / float(planet_radius)
	
	if dragging and event is InputEventMouseMotion:
		rotation_y_target += -event.relative.x * sens * horizontal_sensitivity
		rotation_x_target = clamp(rotation_x_target - event.relative.y * sens * vertical_sensitivity, 
									deg2rad(-89), deg2rad(89))


func _process(delta):
	camera.translation.z = lerp(camera.translation.z, zoom_target, lerp_speed * delta)
	var angle = 90 * angle_curve.interpolate(camera.translation.z / max_height)
	
	
	rotation.y = lerp(rotation.y, rotation_y_target, lerp_speed * delta)
	arm.rotation.x = lerp(arm.rotation.x, rotation_x_target, lerp_speed * delta)
	arm2.rotation.x = deg2rad(angle)
