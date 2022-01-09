extends Spatial


export var size: float = 0.1
export var default_pixel_size: float = 0.005

onready var sprite: Sprite3D = $Sprite3D
onready var label_panel: Control = $Sprite3D/Viewport/Label
onready var label: Control = $Sprite3D/Viewport/Label/Label


func _ready():
	sprite.pixel_size = default_pixel_size
	sprite.texture = $Sprite3D/Viewport.get_texture()
	
	sprite.material_override.albedo_texture = $Sprite3D/Viewport.get_texture()
	sprite.material_override.albedo_texture.set_flags(Texture.FLAG_FILTER | Texture.FLAG_MIPMAPS)


func _process(_delta):
	var height = get_viewport().size.y
	var cam = get_viewport().get_camera().global_transform.origin
	var dist = global_transform.origin.distance_to(cam)
	if dist < Cities.LABEL_MAX_DIST and dist > Cities.LABEL_MIN_DIST:
		scale = Vector3.ONE * (size * dist)
		sprite.pixel_size = default_pixel_size * Consts.DEFAULT_VIEWPORT_HEIGHT / height
		visible = true
	else:
		visible = false


func set_text(text: String):
	label.text = text
	label_panel.rect_size = Vector2(0, 0)

func set_color(color: Color):
	label_panel.self_modulate = color
