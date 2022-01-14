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
const VEG_CLIFFS: int = 9

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
	VEG_CLIFFS: "Cliffs",
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
const LU_IRRIGATED_CROPS: int = 8
const LU_SOLAR_PLANT: int = 9

# Also determined the order of the build options / icons
const LU_NAMES = {
	LU_NONE: "Clear",
	LU_CROPS: "Crops",
	LU_IRRIGATED_CROPS: "Irrigated crops",
	LU_FOREST: "Forest",
	LU_FISHERY: "Fishery",
	LU_FACTORY: "Factory",
	LU_SOLAR_PLANT: "Solar plant",
	LU_MINES: "Mines",
	LU_OIL_RIG: "Oil rig",
	LU_OIL_WELL: "Oil well",
}

const LU_SCENES = {
	LU_NONE: "res://assets/geom/land_use/clear.escn",
	LU_CROPS: "res://assets/geom/land_use/crops.escn",
	LU_IRRIGATED_CROPS: "res://assets/geom/land_use/irr_crops.escn",
	LU_FOREST: "res://assets/geom/land_use/forest.escn",
	LU_FISHERY: "res://assets/geom/land_use/fishery.escn",
	LU_FACTORY: "res://assets/geom/land_use/factory.escn",
	LU_SOLAR_PLANT: "res://assets/geom/land_use/solar_plant.escn",
	LU_MINES: "res://assets/geom/land_use/mines.escn",
	LU_OIL_RIG: "res://assets/geom/land_use/oil_rig.escn",
	LU_OIL_WELL: "res://assets/geom/land_use/oil_well.escn",
}

const LU_ICONS = {
	LU_NONE: preload("res://assets/icons/land_use/clear.svg"),
	LU_CROPS: preload("res://assets/icons/land_use/crops.svg"),
	LU_IRRIGATED_CROPS: preload("res://assets/icons/land_use/irr_crops.svg"),
	LU_FOREST: preload("res://assets/icons/land_use/forest.svg"),
	LU_FISHERY: preload("res://assets/icons/land_use/fishery.svg"),
	LU_FACTORY: preload("res://assets/icons/land_use/factory.svg"),
	LU_SOLAR_PLANT: preload("res://assets/icons/land_use/solar_plant.svg"),
	LU_MINES: preload("res://assets/icons/land_use/mines.svg"),
	LU_OIL_RIG: preload("res://assets/icons/land_use/oil_rig.svg"),
	LU_OIL_WELL: preload("res://assets/icons/land_use/oil_well.svg"),
}

const LU_WORKERS = {
	LU_NONE: 0,
	LU_CROPS: 1,
	LU_IRRIGATED_CROPS: 1,
	LU_FOREST: 1,
	LU_FISHERY: 1,
	LU_FACTORY: 2,
	LU_SOLAR_PLANT: 0,
	LU_MINES: 3,
	LU_OIL_RIG: 3,
	LU_OIL_WELL: 2,
}

const LU_MAINTENANCE = {
	LU_NONE: 0,
	LU_CROPS: 0,
	LU_IRRIGATED_CROPS: 0,
	LU_FOREST: 0,
	LU_FISHERY: 0,
	LU_FACTORY: 1,
	LU_SOLAR_PLANT: 1,
	LU_MINES: 1,
	LU_OIL_RIG: 2,
	LU_OIL_WELL: 1,
}

const LU_OUTPUT = {
	LU_CROPS: Commodities.COMM_FOOD,
	LU_IRRIGATED_CROPS: Commodities.COMM_FOOD,
	LU_FOREST: Commodities.COMM_RESOURCES,
	LU_FISHERY: Commodities.COMM_FOOD,
	LU_FACTORY: Commodities.COMM_PRODUCTS,
	LU_SOLAR_PLANT: Commodities.COMM_ELECTRICITY,
	LU_MINES: Commodities.COMM_RESOURCES,
	LU_OIL_RIG: Commodities.COMM_RESOURCES,
	LU_OIL_WELL: Commodities.COMM_RESOURCES,
}

const LU_RESOURCE = {
	LU_CROPS: null,
	LU_IRRIGATED_CROPS: null,
	LU_FOREST: null,
	LU_FISHERY: null,
	LU_FACTORY: null,
	LU_SOLAR_PLANT: null,
	LU_MINES: Resources.RES_METAL,
	LU_OIL_RIG: Resources.RES_OIL,
	LU_OIL_WELL: Resources.RES_OIL,
}

const LU_REQUIREMENTS = {
	LU_NONE: [],
	LU_CROPS: [],
	LU_IRRIGATED_CROPS: [],
	LU_FOREST: [],
	LU_FISHERY: [Facilities.FAC_PORT],
	LU_FACTORY: [],
	LU_SOLAR_PLANT: [],
	LU_MINES: [],
	LU_OIL_RIG: [Facilities.FAC_PORT],
	LU_OIL_WELL: [],
}

const LU_INFO = {
	LU_NONE: "Clear land use.",
	LU_CROPS: "Grow crops to harvest food.",
	LU_IRRIGATED_CROPS: "Grow crops to harvest food.\n Consumes 1 resource.",
	LU_FOREST: "Grow trees to harvest resources.",
	LU_FISHERY: "Fishes for food.",
	LU_FACTORY: "Transforms resources into products.",
	LU_SOLAR_PLANT: "Generates electricity fom sun light.",
	LU_MINES: "Mines for metal resources.",
	LU_OIL_RIG: "Drills for oil resources off-shore.",
	LU_OIL_WELL: "Drills for oil resources on land.",
}

const LU_KEYS = {
	LU_NONE: KEY_R,
	LU_CROPS: KEY_C,
	LU_IRRIGATED_CROPS: KEY_G,
	LU_FOREST: KEY_F,
	LU_FISHERY: KEY_I,
	LU_FACTORY: KEY_A,
	LU_SOLAR_PLANT: KEY_T,
	LU_MINES: KEY_M,
	LU_OIL_RIG: KEY_O,
	LU_OIL_WELL: KEY_W,
}

var _res_all_land = {VEG_DESERT: null, VEG_TUNDRA: null, VEG_TAIGA: null, VEG_STEPPE: null,
					VEG_TEMPERATE_FOREST: null, VEG_SUBTROPICAL_FOREST: null, VEG_TROPICAL_FOREST: null,
					VEG_CLIFFS: null}
var _factory_lu = VegLandUse.new(null, null, Conversion.new(Commodities.COMM_RESOURCES, 1, Commodities.COMM_PRODUCTS, 1, 5))

var LU_MAPPING = {
	LU_CROPS: {
		VEG_STEPPE: VegLandUse.new(Production.new(Commodities.COMM_FOOD, 1), null, null),
		VEG_TEMPERATE_FOREST: VegLandUse.new(Production.new(Commodities.COMM_FOOD, 2), null, null),
		VEG_SUBTROPICAL_FOREST: VegLandUse.new(Production.new(Commodities.COMM_FOOD, 2), null, null),
		VEG_TROPICAL_FOREST: VegLandUse.new(Production.new(Commodities.COMM_FOOD, 1), null, null),
	},
	LU_IRRIGATED_CROPS: {
		VEG_DESERT: VegLandUse.new(null, null, Conversion.new(Commodities.COMM_RESOURCES, 1, Commodities.COMM_FOOD, 1, 1)),
		VEG_STEPPE: VegLandUse.new(null, null, Conversion.new(Commodities.COMM_RESOURCES, 1, Commodities.COMM_FOOD, 2, 1)),
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
	LU_SOLAR_PLANT: {
		VEG_DESERT: VegLandUse.new(Production.new(Commodities.COMM_ELECTRICITY, 2), null, null),
		VEG_STEPPE: VegLandUse.new(Production.new(Commodities.COMM_ELECTRICITY, 2), null, null),
		VEG_SUBTROPICAL_FOREST: VegLandUse.new(Production.new(Commodities.COMM_ELECTRICITY, 2), null, null),
		VEG_TEMPERATE_FOREST: VegLandUse.new(Production.new(Commodities.COMM_ELECTRICITY, 1), null, null),
	},
	LU_MINES: _res_all_land,
	LU_OIL_RIG: {VEG_WATER: null},
	LU_OIL_WELL: _res_all_land,
}

var LU_RESOURCES = {
	LU_CROPS: {},
	LU_IRRIGATED_CROPS: {},
	LU_FOREST: {},
	LU_FACTORY: {},
	LU_SOLAR_PLANT: {},
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
