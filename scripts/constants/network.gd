class_name Network

const M_ROADS: int = 0
const M_RAIL: int = 1
const M_ELECTRIC: int = 2

const T_CLEAR: int = 0
const T_ROAD: int = 1

const MAX_SLOPE: int = 200

const TYPE_MODE = {
	T_CLEAR: M_ROADS,
	T_ROAD: M_ROADS,
}

const TYPE_ICONS = {
	T_CLEAR: preload("res://assets/icons/facilities/clear_road.svg"),
	T_ROAD: preload("res://assets/icons/facilities/road.svg"),
}

const TYPE_NAMES = {
	T_CLEAR: "Clear roads",
	T_ROAD: "Roads",
}

const TYPE_INFO = {
	T_CLEAR: "Clear roads",
	T_ROAD: "Build roads",
}

const TYPE_CAPACITY = {
	T_CLEAR: 0,
	T_ROAD: 25,
}

const TYPE_KEYS = {
	T_CLEAR: KEY_E,
	T_ROAD: KEY_R,
}

const TYPE_COSTS = {
	T_CLEAR: 0,
	T_ROAD: 5,
}

const TYPE_MAINTENANCE_1000 = {
	T_CLEAR: 0,
	T_ROAD: 250,
}
