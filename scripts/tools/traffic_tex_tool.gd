extends Control

export var background: Color = Color.transparent

export var tile_size: Vector2 = Vector2(128, 32)
export var tiles: Vector2 = Vector2(8, 32)
export var tile_margin: int = 4
export var vehicle_size: Vector2 = Vector2(8, 8)
export var vehicle_y_offset: int = 0

export (Array, int) var num_vehicles: Array = []
export (Array, int) var velocities: Array = []
export (Array, Color) var colors: Array = []


onready var tex_rect = $TextureRect
onready var overlay_rect = $OverlayRect

var texture_size: Vector2
var image: Image
var overlay: Image

func _ready():
	texture_size = Vector2((tile_size.x + 2 * tile_margin) * tiles.x, \
						(tile_size.y + 2 * tile_margin) * tiles.y)
	
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
	var dx = tile_size.x + 2 * tile_margin
	var dy = tile_size.y + 2 * tile_margin
	
	var x0 = col * dx + tile_margin
	for row in range(tiles.y):
		var y0 = row * dy + tile_margin
		var xoff = velocities[col] * row
		var n = num_vehicles[col]
		var x_dist = tile_size.x / float(n) if n > 0 else 0.0
		for i in range(n):
			draw_rect_wrap(image, Vector2(xoff + i * x_dist, vehicle_y_offset), vehicle_size, Vector2(x0, y0), int(tile_size.x), colors[col])


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
	
	var dx = tile_size.x + 2 * tile_margin
	var dy = tile_size.y + 2 * tile_margin
	for i in range(0, tiles.x - 1):
		var x1 = i * dx + tile_margin
		var x2 = (i+1) * dx - tile_margin
		for y in range(texture_size.y):
			overlay.set_pixel(x1, y, Color.dimgray)
			overlay.set_pixel(x2, y, Color.dimgray)
	for i in range(1, tiles.y):
		var y1 = i * dy + tile_margin
		var y2 = (i+1) * dy - tile_margin
		for x in range(texture_size.x):
			overlay.set_pixel(x, y1, Color.dimgray)
			overlay.set_pixel(x, y2, Color.dimgray)
	
	overlay.unlock()
	
	var tex = ImageTexture.new()
	tex.create_from_image(overlay)
	overlay_rect.texture = tex


func _on_SaveButton_pressed():
	if image.save_png("texture.png") != OK:
		print("Error saving image")
