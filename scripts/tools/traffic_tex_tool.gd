extends Control

export var background: Color = Color.transparent

export var texture_size: Vector2 = Vector2(1024, 1024)
export var tiles: Vector2 = Vector2(8, 32)
export var vehicle_size: Vector2 = Vector2(8, 8)
export var vehicle_y_offset: int = 0

export (Array, int) var num_vehicles: Array = []
export (Array, int) var velocities: Array = []
export (Array, Color) var colors: Array = []


onready var tex_rect = $TextureRect
onready var overlay_rect = $OverlayRect

var image: Image
var overlay: Image

func _ready():
	image = Image.new()
	image.create(int(texture_size.x), int(texture_size.y), false, Image.FORMAT_RGBA8)
	image.fill(background)
	
	draw_animations()
	
	var tex = ImageTexture.new()
	tex.create_from_image(image)
	tex_rect.texture = tex
	
	draw_overlay()


func draw_animations():
	for col in range(tiles.x):
		draw_animation(col)


func draw_animation(col: int):
	var dx = texture_size.x / tiles.x
	var dy = texture_size.y / tiles.y
	
	var x0 = int(col * dx)
	print("anim %d" % col)
	for row in range(tiles.y):
		var y0 = int(row * dy)
		var xoff = velocities[col] * row
		var n = num_vehicles[col]
		var x_dist = dx / n if n > 0 else 0
		for i in range(n):
			draw_rect_wrap(image, Vector2(xoff + i * x_dist, vehicle_y_offset), vehicle_size, Vector2(x0, y0), dx, colors[col])


func draw_rect_wrap(img: Image, pos: Vector2, size: Vector2, origin: Vector2, width: int, color: Color):
	img.lock()
	for xx in range(pos.x, pos.x + size.x):
		for yy in range(pos.y, pos.y + size.y):
			var xxx = origin.x + xx % width
			var yyy = origin.y + yy
			img.set_pixel(xxx, yyy, color)
	img.unlock()


func draw_overlay():
	overlay = Image.new()
	overlay.create(int(texture_size.x), int(texture_size.y), false, Image.FORMAT_RGBA8)
	
	overlay.fill(Color.transparent)
	overlay.lock()
	
	var dx = texture_size.x / tiles.x
	var dy = texture_size.y / tiles.y
	for i in range(1, tiles.x):
		var x = int(i * dx)
		for y in range(texture_size.y):
			overlay.set_pixel(x, y, Color.dimgray)
	for i in range(1, tiles.y):
		var y = int(i * dy)
		for x in range(texture_size.x):
			overlay.set_pixel(x, y, Color.dimgray)
	
	overlay.unlock()
	
	var tex = ImageTexture.new()
	tex.create_from_image(overlay)
	overlay_rect.texture = tex


func _on_SaveButton_pressed():
	if image.save_png("texture.png") != OK:
		print("Error saving image")
