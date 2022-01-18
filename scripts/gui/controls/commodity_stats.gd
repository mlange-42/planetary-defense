extends Control
class_name CommodityStats

export (int, "Food", "Resources", "Products", "Electricity") var commodity: int = 0

onready var icon: TextureRect = find_node("Icon")
onready var production_bar: TwoValueBar = find_node("ProductionBar")
onready var consumption_bar: TwoValueBar = find_node("ConsumptionBar")
onready var production: Label = find_node("Production")
onready var supply: Label = find_node("Supply")
onready var demand: Label = find_node("Demand")

func _ready():
	icon.hint_tooltip = Commodities.COMM_NAMES[commodity]
	icon.texture = Commodities.COMM_ICONS[commodity]


func set_values(source: int, received: int, sink: int):
	supply.text = "%+3d" % source
	demand.text = "%+3d" % -sink
	production.text = "%3d" % received
	
	var mx = max(source, sink)
	production_bar.set_values(source, received, mx)
	consumption_bar.set_values(sink, received, mx)
