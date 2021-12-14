tool
extends Node2D
class_name NetNode

export var source: int = 0
export var sink: int = 0

onready var sprite: Sprite = $Sprite
onready var source_sprite: Sprite = $Sprite/Source
onready var sink_sprite: Sprite = $Sprite/Sink
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
	$SourceLabel.text = "%d/%d" % [value, source]
	$SourceLabel.visible = true

func set_sink_amount(value: int):
	var v = value / float(sink)
	sink_sprite.self_modulate = Colors.heat_map(v)
	$SinkLabel.text = "%d/%d" % [value, sink]
	$SinkLabel.visible = true

func _set_appearance():
	if source > sink:
		$Sprite.self_modulate = Color.green
	elif sink > source:
		$Sprite.self_modulate = Color.red
	else:
		$Sprite.self_modulate = Color.gray
	
	if source_sprite != null:
		source_sprite.self_modulate = Color.black
	if sink_sprite != null:
		sink_sprite.self_modulate = Color.black
	
	scale = Vector2.ONE
	var sc = 0.2 + abs(source - sink) / 100.0
	#$Sprite.scale = Vector2.ONE
	$Sprite.scale = Vector2.ONE * sc
	
	$Label.text = "+%d/-%d" % [source, sink]
	
