extends Spatial

export var speed: float = 90

func _physics_process(delta):
	rotate_y(deg2rad(speed) * delta)
