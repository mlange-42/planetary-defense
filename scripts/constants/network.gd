class_name Network

const MODE_OFFSET: int = 1_000_000

const M_ROADS: int = 0
const M_RAIL: int = 1
const M_ELECTRIC: int = 2

const T_CLEAR: int = 0
const T_ROAD: int = 1
const T_POWER_LINE: int = 20

const MAX_SLOPE: int = 200

const TYPE_MODES = {
	T_CLEAR: M_ROADS,
	T_ROAD: M_ROADS,
	T_POWER_LINE: M_ELECTRIC,
}

const TYPE_ICONS = {
	T_CLEAR: preload("res://assets/icons/facilities/clear_road.svg"),
	T_ROAD: preload("res://assets/icons/facilities/road.svg"),
	T_POWER_LINE: preload("res://assets/icons/facilities/power_line.svg"),
}

const TYPE_NAMES = {
	T_CLEAR: "Clear roads",
	T_ROAD: "Roads",
	T_POWER_LINE: "Power Lines",
}

const TYPE_INFO = {
	T_CLEAR: "Clear roads",
	T_ROAD: "On roads, food, resources and products are transported",
	T_POWER_LINE: "Power lines transport electricity",
}

const TYPE_CAPACITY = {
	T_CLEAR: 0,
	T_ROAD: 25,
	T_POWER_LINE: 25,
}

const TYPE_KEYS = {
	T_CLEAR: KEY_E,
	T_ROAD: KEY_R,
	T_POWER_LINE: KEY_P,
}

const TYPE_COSTS = {
	T_CLEAR: 0,
	T_ROAD: 5,
	T_POWER_LINE: 5,
}

const TYPE_MAINTENANCE_1000 = {
	T_CLEAR: 0,
	T_ROAD: 250,
	T_POWER_LINE: 250,
}

func to_base_id(id: int) -> int:
	return id % MODE_OFFSET

func to_mode_id(id: int, tp: int) -> int:
	return (id % MODE_OFFSET) + tp * MODE_OFFSET

func get_mode(id: int) -> int:
	# warning-ignore:integer_division
	return id / MODE_OFFSET
