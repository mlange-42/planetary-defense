class_name Network

const MODE_OFFSET: int = 1_000_000

# Parallels Rust consts in PlanetData
const NAV_ALL: int = 0
const NAV_LAND: int = 1
const NAV_WATER: int = 2


const M_ROADS: int = 0
const M_RAIL: int = 1
const M_ELECTRIC: int = 2
const M_SEA: int = 3

const ALL_MODES: Array = [M_ROADS, M_RAIL, M_ELECTRIC]

const MODE_NAV = {
	M_ROADS: NAV_LAND,
	M_RAIL: NAV_LAND,
	M_ELECTRIC: NAV_LAND,
	M_SEA: NAV_WATER,
}

const MODE_BLOCK = {
	M_ROADS: [M_RAIL],
	M_RAIL: [M_ROADS],
	M_ELECTRIC: [],
	M_SEA: [],
}


const T_CLEAR: int = 0
const T_ROAD: int = 1
const T_RAIL: int = 10
const T_POWER_LINE: int = 20
const T_SEA_LINE: int = 30

const MAX_SLOPE: int = 200

const TYPE_MODES = {
	T_CLEAR: M_ROADS,
	T_ROAD: M_ROADS,
	T_RAIL: M_RAIL,
	T_POWER_LINE: M_ELECTRIC,
	T_SEA_LINE: M_SEA,
}

const TYPE_ICONS = {
	T_CLEAR: preload("res://assets/icons/network/clear_road.svg"),
	T_ROAD: preload("res://assets/icons/network/road.svg"),
	T_RAIL: preload("res://assets/icons/network/rail.svg"),
	T_SEA_LINE: preload("res://assets/icons/network/sea_line.svg"),
	T_POWER_LINE: preload("res://assets/icons/network/power_line.svg"),
}

const TYPE_NAMES = {
	T_CLEAR: "Clear roads",
	T_ROAD: "Roads",
	T_RAIL: "Railways",
	T_SEA_LINE: "Sea line",
	T_POWER_LINE: "Power Lines",
}

const TYPE_INFO = {
	T_CLEAR: "Clear roads",
	T_ROAD: "On roads, food, resources and products are transported",
	T_RAIL: "On railways, large amounts of food, resources and products are transported",
	T_SEA_LINE: "On sea lines, food, resources and products are shipped",
	T_POWER_LINE: "Power lines transport electricity",
}

const TYPE_DRAW_WIDTH = {
	T_CLEAR: 0.03,
	T_ROAD: 0.03,
	T_RAIL: 0.04,
	T_SEA_LINE: 0.03,
	T_POWER_LINE: 0.03,
}

const TYPE_CAPACITY = {
	T_CLEAR: 0,
	T_ROAD: 25,
	T_RAIL: 100,
	T_SEA_LINE: 50,
	T_POWER_LINE: 50,
}

const TYPE_COSTS = {
	T_CLEAR: 0,
	T_ROAD: 5,
	T_RAIL: 25,
	T_SEA_LINE: 5,
	T_POWER_LINE: 5,
}

const TYPE_TRANSPORT_COST_1000 = {
	T_CLEAR: 0,
	T_ROAD: 25,
	T_RAIL: 10,
	T_SEA_LINE: 20,
	T_POWER_LINE: 5,
}

const TYPE_MAINTENANCE_1000 = {
	T_CLEAR: 0,
	T_ROAD: 250,
	T_RAIL: 500,
	T_SEA_LINE: 100,
	T_POWER_LINE: 100,
}

const TYPE_KEYS = {
	T_CLEAR: KEY_E,
	T_ROAD: KEY_O,
	T_RAIL: KEY_R,
	T_SEA_LINE: KEY_S,
	T_POWER_LINE: KEY_P,
}

static func to_base_id(id: int) -> int:
	return id % MODE_OFFSET

static func to_mode_id(id: int, tp: int) -> int:
	return (id % MODE_OFFSET) + tp * MODE_OFFSET

static func get_mode(id: int) -> int:
	# warning-ignore:integer_division
	return id / MODE_OFFSET
