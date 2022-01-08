extends Control
class_name CommodityStats

export (String, "Food", "Resources", "Products") var commodity: String = "Food"

onready var icon = find_node("Icon")
onready var production = find_node("Production")
onready var supply = find_node("Supply")
onready var demand = find_node("Demand")

func _ready():
	icon.hint_tooltip = commodity
	icon = load(Commodities.COMM_ICONS[commodity])


func set_values(source: int, moved: int, sink: int):
	supply.text = str(source)
	production.text = str(moved)
	demand.text = str(sink)
