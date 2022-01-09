extends Control
class_name CommodityStats

export (String, "Food", "Resources", "Products") var commodity: String = "Food"

onready var icon: TextureRect = find_node("Icon")
onready var production: Label = find_node("Production")
onready var supply: Label = find_node("Supply")
onready var demand: Label = find_node("Demand")

func _ready():
	icon.hint_tooltip = commodity
	icon.texture = Commodities.COMM_ICONS[commodity]


func set_values(source: int, sent: int, received: int, sink: int):
	supply.text = "%+4d" % source
	demand.text = "%+4d" % -sink
	if sent < 0:
		production.text = "%3d" % received
	else:
		production.text = "%7s" % ("%d/%d" % [sent, received])
