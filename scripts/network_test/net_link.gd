tool
extends Node2D
class_name NetLink

export var start: NodePath
export var end: NodePath
export var capacity: int = 100
export var cost: int = 1

onready var label: Label = $Label

func _ready():
	if not Engine.editor_hint:
		_set_appearance()


func _process(_delta):
	if Engine.editor_hint:
		_set_appearance()


func set_amount(value: int):
	if value == 0:
		modulate = Color(0.3, 0.3, 0.3)
	else:
		var v = value/float(capacity)
		modulate = Colors.heat_map(1-v)
	label.text = "%d/%d" % [value, capacity]


func _set_appearance():
	if start.is_empty() or end.is_empty():
		return
	
	var start_node: NetNode = get_node(start)
	var end_node: NetNode = get_node(end)
	
	if start_node == null or end_node == null:
		return
	
	position = (start_node.position + end_node.position) / 2
	look_at(end_node.position)
	
	var scx = (end_node.position - start_node.position).length() / $Sprite.texture.get_width()
	var scy = 2 * capacity / 100.0
	$Sprite.scale = Vector2(scx, scy)
	
