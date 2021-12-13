extends Spatial


export var planet_radius: float = 10.0
export var horizontal_sensitivity: float = 0.00015
export var vertical_sensitivity: float = 0.00015
export var zoom_increment: float = 1.0
export var lerp_speed: float = 10

onready var arm: Spatial = $Arm
onready var camera: Camera = $Arm/Camera

var dragging: bool = false
var zoom_target: float
var rotation_x_target: float
var rotation_y_target: float


func _ready():
	zoom_target = camera.translation.z
	rotation_x_target = arm.rotation.x
	rotation_y_target = rotation.y


func _input(event) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT:
			dragging = event.pressed
		elif event.button_index == BUTTON_WHEEL_UP:
			zoom_target = clamp(zoom_target + zoom_increment, planet_radius + 2, planet_radius * 4)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			zoom_target = clamp(zoom_target - zoom_increment, planet_radius + 2, planet_radius * 4)
	
	var sens = camera.translation.z
	
	if dragging and event is InputEventMouseMotion:
		rotation_y_target += -event.relative.x * sens * horizontal_sensitivity
		rotation_x_target = clamp(rotation_x_target - event.relative.y * sens * vertical_sensitivity, 
									deg2rad(-89), deg2rad(89))


func _process(delta):
	camera.translation.z = lerp(camera.translation.z, zoom_target, lerp_speed * delta)
	
	rotation.y = lerp(rotation.y, rotation_y_target, lerp_speed * delta)
	arm.rotation.x = lerp(arm.rotation.x, rotation_x_target, lerp_speed * delta)
