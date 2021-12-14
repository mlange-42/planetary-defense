tool
extends Sprite
class_name NetNode

export var source: int = 0
export var sink: int = 0

onready var source_sprite: Sprite = $Source
onready var sink_sprite: Sprite = $Sink
onready var label: Label = $Label

var id: int = 0

func _ready():
	if not Engine.editor_hint:
		_set_appearance()
		label.text = "+%d/-%d" % [source, sink]


func _process(_delta):
	if Engine.editor_hint:
		_set_appearance()

func set_source_amount(value: int):
	var v = value / float(source)
	source_sprite.self_modulate = Colors.heat_map(v)

func set_sink_amount(value: int):
	var v = value / float(sink)
	sink_sprite.self_modulate = Colors.heat_map(v)

func _set_appearance():
	if source > sink:
		self_modulate = Color.green
	elif sink > source:
		self_modulate = Color.red
	else:
		self_modulate = Color.gray
	
	if source_sprite != null:
		source_sprite.self_modulate = Color.black
	if sink_sprite != null:
		sink_sprite.self_modulate = Color.black
	
	scale = Vector2.ONE * (0.2 + abs(source - sink) / 100.0)
