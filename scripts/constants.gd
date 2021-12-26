extends Node
class_name Constants

class VegLandUse:
	var source
	var sink
	var conversion
	func _init(sources, sinks, conversions):
		self.source = sources
		self.sink = sinks
		self.conversion = conversions

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

const CITY_GROWTH_PROB: float = 0.25

const DRAW_HEIGHT_OFFSET: float = 0.02

const FACILITY_SCENES = {
	"city": "res://scenes/objects/city.tscn",
}

const COMM_FOOD: String = "Food"
const COMM_RESOURCES: String = "Resources"
const COMM_PRODUCTS: String = "Products"

const COMM_ALL = [COMM_FOOD, COMM_RESOURCES, COMM_PRODUCTS]

const VEG_DESERT: int = 0
const VEG_GLACIER: int = 1
const VEG_TUNDRA: int = 2
const VEG_TAIGA: int = 3
const VEG_STEPPE: int = 4
const VEG_TEMPERATE_FOREST: int = 5
const VEG_SUBTROPICAL_FOREST: int = 6
const VEG_TROPICAL_FOREST: int = 7
const VEG_WATER: int = 8

const VEG_NAMES = {
	VEG_DESERT: "Desert",
	VEG_GLACIER: "Glacier",
	VEG_TUNDRA: "Tundra",
	VEG_TAIGA: "Taiga",
	VEG_STEPPE: "Steppe",
	VEG_TEMPERATE_FOREST: "Temperate forest",
	VEG_SUBTROPICAL_FOREST: "Subtropical forest",
	VEG_TROPICAL_FOREST: "Tropical forest",
	VEG_WATER: "Water",
}

const LU_NONE = 0
const LU_CROPS = 1
const LU_FOREST = 2
const LU_FACTORY = 3
const LU_FISHERY = 4

const LU_COLORS = {
	LU_NONE: Color.gray,
	LU_CROPS: Color.yellow,
	LU_FOREST: Color.black,
	LU_FACTORY: Color.red,
	LU_FISHERY: Color.aqua,
}

const LU_NAMES = {
	LU_NONE: "Clear",
	LU_CROPS: "Crops",
	LU_FOREST: "Forest",
	LU_FACTORY: "Factory",
	LU_FISHERY: "Fishery",
}

const LU_WORKERS = {
	LU_NONE: 0,
	LU_CROPS: 1,
	LU_FOREST: 1,
	LU_FACTORY: 3,
	LU_FISHERY: 1,
}

const LU_OUTPUT = {
	LU_CROPS: COMM_FOOD,
	LU_FOREST: COMM_RESOURCES,
	LU_FACTORY: COMM_PRODUCTS,
	LU_FISHERY: COMM_FOOD,
}

var _factory_lu = VegLandUse.new(null, null, Conversion.new(COMM_RESOURCES, 1, COMM_PRODUCTS, 1, 5))

var LU_MAPPING = {
	LU_CROPS: {
		VEG_STEPPE: VegLandUse.new(Production.new(COMM_FOOD, 1), null, null),
		VEG_TEMPERATE_FOREST: VegLandUse.new(Production.new(COMM_FOOD, 2), null, null),
		VEG_SUBTROPICAL_FOREST: VegLandUse.new(Production.new(COMM_FOOD, 2), null, null),
		VEG_TROPICAL_FOREST: VegLandUse.new(Production.new(COMM_FOOD, 1), null, null),
	},
	LU_FOREST: {
		VEG_TEMPERATE_FOREST: VegLandUse.new(Production.new(COMM_RESOURCES, 2), null, null),
		VEG_SUBTROPICAL_FOREST: VegLandUse.new(Production.new(COMM_RESOURCES, 1), null, null),
		VEG_TROPICAL_FOREST: VegLandUse.new(Production.new(COMM_RESOURCES, 3), null, null),
	},
	LU_FACTORY: {
		VEG_DESERT: _factory_lu,
		VEG_TUNDRA: _factory_lu,
		VEG_TAIGA: _factory_lu,
		VEG_STEPPE: _factory_lu,
		VEG_TEMPERATE_FOREST: _factory_lu,
		VEG_SUBTROPICAL_FOREST: _factory_lu,
		VEG_TROPICAL_FOREST: _factory_lu,
	},
	LU_FISHERY: {
		VEG_WATER: VegLandUse.new(Production.new(COMM_FOOD, 2), null, null),
	},
}

var VEG_MAPPING = remap(LU_MAPPING)

func remap(map: Dictionary) -> Dictionary:
	var res = {}
	for k1 in map:
		var map2 = map[k1]
		for k2 in map2:
			if not k2 in res:
				res[k2] = {}
			res[k2][k1] = map2[k2]
	
	return res
