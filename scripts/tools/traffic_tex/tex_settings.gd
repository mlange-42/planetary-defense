extends Node
class_name TexSettings

export (String, FILE, "*.png") var output_file: String

export var background: Color = Color.transparent

export var tile_size: Vector2 = Vector2(128, 32)
export var tiles: Vector2 = Vector2(8, 32)
export var tile_margin: int = 4
export var vehicle_y_offset: int = 0

export var vehicle_width: int = 8

export (Array, int) var num_vehicles: Array = []
export (Array, int) var vehicle_lengths: Array = []
export (Array, float) var velocities: Array = []
export (Array, Color) var colors: Array = []
