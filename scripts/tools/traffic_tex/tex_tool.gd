extends Control

onready var tex_rect = $TextureRect
onready var overlay_rect = $OverlayRect
onready var set: TexSettings = $Settings

var texture_size: Vector2
var image: Image
var overlay: Image

func _ready():
	texture_size = Vector2((set.tile_size.x + 2 * set.tile_margin) * set.tiles.x, \
						(set.tile_size.y + 2 * set.tile_margin) * set.tiles.y)
	
	image = Image.new()
	image.create(int(texture_size.x), int(texture_size.y), false, Image.FORMAT_RGBA8)
	image.fill(set.background)
	
	draw_animations()
	
	var tex = ImageTexture.new()
	tex.create_from_image(image)
	tex_rect.texture = tex
	
	draw_overlay()


func draw_animations():
	for col in range(set.tiles.x):
		draw_animation(col)


func draw_animation(col: int):
	var dx = set.tile_size.x + 2 * set.tile_margin
	var dy = set.tile_size.y + 2 * set.tile_margin
	
	var x0 = col * dx + set.tile_margin
	for row in range(set.tiles.y):
		var y0 = row * dy + set.tile_margin
		var xoff = set.velocities[col] * row
		var n = set.num_vehicles[col]
		var x_dist = set.tile_size.x / float(n) if n > 0 else 0.0
		for i in range(n):
			draw_rect_wrap(image, Vector2(xoff + i * x_dist, set.vehicle_y_offset), \
								Vector2(set.vehicle_lengths[col], set.vehicle_width), \
								Vector2(x0, y0), int(set.tile_size.x), set.colors[col])


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
	
	var tm = set.tile_margin
	var dx = set.tile_size.x + 2 * tm
	var dy = set.tile_size.y + 2 * tm
	for i in range(0, set.tiles.x - 1):
		var x1 = i * dx + tm
		var x2 = (i+1) * dx - tm
		for y in range(texture_size.y):
			overlay.set_pixel(x1, y, Color.dimgray)
			overlay.set_pixel(x2, y, Color.dimgray)
	for i in range(0, set.tiles.y - 1):
		var y1 = i * dy + tm
		var y2 = (i+1) * dy - tm
		for x in range(texture_size.x):
			overlay.set_pixel(x, y1, Color.dimgray)
			overlay.set_pixel(x, y2, Color.dimgray)
	
	overlay.unlock()
	
	var tex = ImageTexture.new()
	tex.create_from_image(overlay)
	overlay_rect.texture = tex


func _on_SaveButton_pressed():
	if image.save_png(set.output_file) != OK:
		print("Error saving image")
