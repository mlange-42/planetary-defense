extends HBoxContainer
class_name CommodityStatsSimple

var commodity: String

onready var icon: TextureRect
onready var label: Label


func _init(comm: String, amount: int):
	commodity = comm
	
	icon = TextureRect.new()
	icon.texture = Commodities.COMM_ICONS[comm]
	icon.rect_min_size = Vector2(16, 16)
	icon.expand = true
	
	icon.hint_tooltip = commodity
	icon.texture = Commodities.COMM_ICONS[commodity]
	
	add_child(icon)
	
	label = Label.new()
	label.text = "%3d" % amount
	
	add_child(label)


func set_amount(amount: int):
	label.text = "%3d" % amount