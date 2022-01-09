extends Spatial


export var min_dist: float = 0.0
export var max_dist: float = 1000.0
export var size: float = 1.0
export var default_pixel_size: float = 0.006
export var offset: Vector3

onready var sprite: Sprite3D = $Sprite3D

var _shown: bool = true setget set_shown, is_shown

func _ready():
	sprite.pixel_size = default_pixel_size
	sprite.translation = offset


func _process(_delta):
	var height = get_viewport().size.y
	var cam = get_viewport().get_camera().global_transform.origin
	var dist = global_transform.origin.distance_to(cam)
	if dist > min_dist and dist < max_dist:
		scale = Vector3.ONE * (size * dist)
		sprite.pixel_size = default_pixel_size * Consts.DEFAULT_VIEWPORT_HEIGHT / height
		visible = true and _shown
	else:
		visible = false


func is_shown():
	return _shown


func set_shown(vis: bool):
	_shown = vis
