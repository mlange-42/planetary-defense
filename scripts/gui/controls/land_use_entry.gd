extends VBoxContainer
class_name LandUseEntry

var land_use: TextureRect
var amount: Label
var commodity: TextureRect

func _init(lu: int, comm: String, amnt: int):
	self.size_flags_horizontal = 0
	
	land_use = TextureRect.new()
	land_use.texture = load(LandUse.LU_ICONS[lu])
	
	commodity = TextureRect.new()
	if not comm.empty():
		commodity.texture = load(Commodities.COMM_ICONS[comm])
	
	amount = Label.new()
	if not comm.empty():
		amount.add_font_override("font", load("res://assets/fonts/consolas_20.tres"))
		amount.text = str(amnt)
	amount.align = HALIGN_CENTER
	
	add_child(land_use)
	add_child(amount)
	add_child(commodity)
