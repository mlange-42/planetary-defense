extends Control
class_name CityCommodityStats

export (int, "Food", "Resources", "Products", "Electricity") var commodity: int = 0
export var dim_color: Color = Color.dimgray

onready var icon: TextureRect = find_node("Icon")

onready var production_bar: Control = find_node("ProductionBar")
onready var consumption_bar: Control = find_node("ConsumptionBar")

onready var production_label: Control = find_node("ProductionLabel")
onready var source_label: Control = find_node("SourceLabel")
onready var consumption_label: Control = find_node("ConsumptionLabel")
onready var sink_label: Control = find_node("SinkLabel")

func _ready():
	icon.hint_tooltip = Commodities.COMM_NAMES[commodity]
	icon.texture = Commodities.COMM_ICONS[commodity]


func set_values(source: int, sent: int, received: int, sink: int):
	var mx = max(source, sink)
	production_bar.set_values(sent, source, mx)
	consumption_bar.set_values(received, sink, mx)
	
	production_label.text = "%3d" % sent
	source_label.text = "%3d" % source
	
	consumption_label.text = "%3d" % received
	sink_label.text = "%3d" % sink
	
	if source + sent + received + sink == 0:
		modulate = dim_color
	else:
		modulate = Color.white
