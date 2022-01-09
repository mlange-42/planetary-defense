extends Node
class_name LandUse


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


const VEG_RESOURCES = {
	Resources.RES_METAL: {
		VEG_DESERT: {
			"probability": 0.005,
			"radius": 0,
			"amount": 2500,
			"elevation": [0.0, 1.0],
		},
		VEG_TAIGA: {
			"probability": 0.01,
			"radius": 0,
			"amount": 2500,
			"elevation": [0.2, 1.0],
		},
		VEG_STEPPE: {
			"probability": 0.01,
			"radius": 0,
			"amount": 2500,
			"elevation": [0.2, 1.0],
		},
	},
	Resources.RES_OIL: {
		VEG_DESERT: {
			"probability": 0.001,
			"radius": 1,
			"amount": 1000,
			"elevation": [0.0, 0.1],
		},
		VEG_WATER: {
			"probability": 0.002,
			"radius": 1,
			"amount": 1000,
			"elevation": [-0.2, 0.0],
		},
	},
}


const LU_NONE: int = 0
const LU_CROPS: int = 1
const LU_FOREST: int = 2
const LU_FISHERY: int = 3
const LU_FACTORY: int = 4
const LU_MINES: int = 5
const LU_OIL_RIG: int = 6
const LU_OIL_WELL: int = 7

const LU_COLORS = {
	LU_NONE: Color.gray,
	LU_CROPS: Color.yellow,
	LU_FOREST: Color.black,
	LU_FISHERY: Color.aqua,
	LU_FACTORY: Color.red,
	LU_MINES: Color.magenta,
	LU_OIL_RIG: Color.magenta,
	LU_OIL_WELL: Color.magenta,
}

const LU_SCENES = {
	LU_NONE: "res://assets/geom/clear.escn",
	LU_CROPS: "res://assets/geom/crops.escn",
	LU_FOREST: "res://assets/geom/forest.escn",
	LU_FISHERY: "res://assets/geom/fishery.escn",
	LU_FACTORY: "res://assets/geom/factory.escn",
	LU_MINES: "res://assets/geom/mines.escn",
	LU_OIL_RIG: "res://assets/geom/oil_rig.escn",
	LU_OIL_WELL: "res://assets/geom/oil_well.escn",
}

const LU_ICONS = {
	LU_NONE: preload("res://assets/icons/land_use/clear.svg"),
	LU_CROPS: preload("res://assets/icons/land_use/crops.svg"),
	LU_FOREST: preload("res://assets/icons/land_use/forest.svg"),
	LU_FISHERY: preload("res://assets/icons/land_use/fishery.svg"),
	LU_FACTORY: preload("res://assets/icons/land_use/factory.svg"),
	LU_MINES: preload("res://assets/icons/land_use/mines.svg"),
	LU_OIL_RIG: preload("res://assets/icons/land_use/oil_rig.svg"),
	LU_OIL_WELL: preload("res://assets/icons/land_use/oil_well.svg"),
}

const LU_NAMES = {
	LU_NONE: "Clear",
	LU_CROPS: "Crops",
	LU_FOREST: "Forest",
	LU_FISHERY: "Fishery",
	LU_FACTORY: "Factory",
	LU_MINES: "Mines",
	LU_OIL_RIG: "Oil rig",
	LU_OIL_WELL: "Oil well",
}

const LU_WORKERS = {
	LU_NONE: 0,
	LU_CROPS: 1,
	LU_FOREST: 1,
	LU_FISHERY: 1,
	LU_FACTORY: 2,
	LU_MINES: 3,
	LU_OIL_RIG: 3,
	LU_OIL_WELL: 2,
}

const LU_MAINTENANCE = {
	LU_NONE: 0,
	LU_CROPS: 0,
	LU_FOREST: 0,
	LU_FISHERY: 0,
	LU_FACTORY: 1,
	LU_MINES: 1,
	LU_OIL_RIG: 2,
	LU_OIL_WELL: 1,
}

const LU_OUTPUT = {
	LU_CROPS: Commodities.COMM_FOOD,
	LU_FOREST: Commodities.COMM_RESOURCES,
	LU_FISHERY: Commodities.COMM_FOOD,
	LU_FACTORY: Commodities.COMM_PRODUCTS,
	LU_MINES: Commodities.COMM_RESOURCES,
	LU_OIL_RIG: Commodities.COMM_RESOURCES,
	LU_OIL_WELL: Commodities.COMM_RESOURCES,
}

const LU_RESOURCE = {
	LU_CROPS: null,
	LU_FOREST: null,
	LU_FISHERY: null,
	LU_FACTORY: null,
	LU_MINES: Resources.RES_METAL,
	LU_OIL_RIG: Resources.RES_OIL,
	LU_OIL_WELL: Resources.RES_OIL,
}

const LU_REQUIREMENTS = {
	LU_NONE: [],
	LU_CROPS: [],
	LU_FOREST: [],
	LU_FISHERY: [Facilities.FAC_PORT],
	LU_FACTORY: [],
	LU_MINES: [],
	LU_OIL_RIG: [Facilities.FAC_PORT],
	LU_OIL_WELL: [],
}

const LU_INFO = {
	LU_NONE: "Clear land use.",
	LU_CROPS: "Grow crops to harvest food.",
	LU_FOREST: "Grow crops to harvest resources.",
	LU_FISHERY: "Fishes for food.",
	LU_FACTORY: "Transforms resources into products.",
	LU_MINES: "Mines for metal resources.",
	LU_OIL_RIG: "Drills for oil resources off-shore.",
	LU_OIL_WELL: "Drills for oil resources on land.",
}

const LU_KEYS = {
	LU_NONE: KEY_R,
	LU_CROPS: KEY_C,
	LU_FOREST: KEY_F,
	LU_FISHERY: KEY_I,
	LU_FACTORY: KEY_A,
	LU_MINES: KEY_M,
	LU_OIL_RIG: KEY_O,
	LU_OIL_WELL: KEY_W,
}

var _res_all_land = {VEG_DESERT: null, VEG_TUNDRA: null, VEG_TAIGA: null, VEG_STEPPE: null,
					VEG_TEMPERATE_FOREST: null, VEG_SUBTROPICAL_FOREST: null, VEG_TROPICAL_FOREST: null}
var _factory_lu = VegLandUse.new(null, null, Conversion.new(Commodities.COMM_RESOURCES, 1, Commodities.COMM_PRODUCTS, 1, 5))

var LU_MAPPING = {
	LU_CROPS: {
		VEG_STEPPE: VegLandUse.new(Production.new(Commodities.COMM_FOOD, 1), null, null),
		VEG_TEMPERATE_FOREST: VegLandUse.new(Production.new(Commodities.COMM_FOOD, 2), null, null),
		VEG_SUBTROPICAL_FOREST: VegLandUse.new(Production.new(Commodities.COMM_FOOD, 2), null, null),
		VEG_TROPICAL_FOREST: VegLandUse.new(Production.new(Commodities.COMM_FOOD, 1), null, null),
	},
	LU_FOREST: {
		VEG_TAIGA: VegLandUse.new(Production.new(Commodities.COMM_RESOURCES, 1), null, null),
		VEG_TEMPERATE_FOREST: VegLandUse.new(Production.new(Commodities.COMM_RESOURCES, 1), null, null),
		VEG_SUBTROPICAL_FOREST: VegLandUse.new(Production.new(Commodities.COMM_RESOURCES, 1), null, null),
		VEG_TROPICAL_FOREST: VegLandUse.new(Production.new(Commodities.COMM_RESOURCES, 2), null, null),
	},
	LU_FISHERY: {
		VEG_WATER: VegLandUse.new(Production.new(Commodities.COMM_FOOD, 2), null, null),
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
	LU_MINES: _res_all_land,
	LU_OIL_RIG: {VEG_WATER: null},
	LU_OIL_WELL: _res_all_land,
}

var LU_RESOURCES = {
	LU_CROPS: {},
	LU_FOREST: {},
	LU_FACTORY: {},
	LU_FISHERY: {},
	LU_MINES: {
		Resources.RES_METAL: VegLandUse.new(Production.new(Commodities.COMM_RESOURCES, 10), null, null),
	},
	LU_OIL_RIG: {
		Resources.RES_OIL: VegLandUse.new(Production.new(Commodities.COMM_RESOURCES, 10), null, null),
	},
	LU_OIL_WELL: {
		Resources.RES_OIL: VegLandUse.new(Production.new(Commodities.COMM_RESOURCES, 6), null, null),
	},
}

var VEG_MAPPING = _remap(LU_MAPPING)
var RES_MAPPING = _remap(LU_RESOURCES)

func _remap(map: Dictionary) -> Dictionary:
	var res = {}
	for k1 in map:
		var map2 = map[k1]
		for k2 in map2:
			if not k2 in res:
				res[k2] = {}
			res[k2][k1] = map2[k2]
	
	return res

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
