class_name Constants

class Production:
	export var commodity: String
	export var amount: int
	func _init(com: String, amt: int):
		commodity = com
		amount = amt

class Conversion:
	var from: String
	var from_amount: int
	var max_from_amount: int
	var to: String
	var to_amount: int
	func _init(f: String, f_amt: int, t: String, t_amt: int, max_amount: int):
		from = f
		from_amount = f_amt
		max_from_amount = max_amount
		to = t
		to_amount = t_amt

const DRAW_HEIGHT_OFFSET: float = 0.02

const FACILITY_SCENES = {
	"city": "res://scenes/objects/city.tscn",
}

const COMM_FOOD: String = "Food"
const COMM_RESOURCES: String = "Resources"
const COMM_PRODUCTS: String = "Products"

const VEG_DESERT: int = 0
const VEG_GLACIER: int = 1
const VEG_TUNDRA: int = 2
const VEG_TAIGA: int = 3
const VEG_STEPPE: int = 4
const VEG_TEMPERATE_FOREST: int = 5
const VEG_SUBTROPICAL_FOREST: int = 6
const VEG_TROPICAL_FOREST: int = 7
const VEG_WATER: int = 8

const LU_NONE = 0
const LU_CROPS = 1
const LU_PASTURE = 2
const LU_FOREST = 3
const LU_MINE = 4
const LU_FACTORY = 5
