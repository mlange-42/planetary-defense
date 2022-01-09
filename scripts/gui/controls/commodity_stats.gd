extends Control
class_name CommodityStats

export (String, "Food", "Resources", "Products") var commodity: String = "Food"

onready var icon: TextureRect = find_node("Icon")
onready var production: Label = find_node("Production")
onready var supply: Label = find_node("Supply")
onready var demand: Label = find_node("Demand")

func _ready():
	icon.hint_tooltip = commodity
	icon.texture = load(Commodities.COMM_ICONS[commodity])


func set_values(source: int, sent: int, received: int, sink: int):
	supply.text = str(source)
	if sent < 0:
		production.text = str(received)
	else:
		production.text = "%d/%d" % [sent, received]
	demand.text = str(sink)
