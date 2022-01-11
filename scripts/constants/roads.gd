class_name Roads

const ROAD_CLEAR: int = 0
const ROAD_ROAD: int = 1

const MAX_SLOPE: int = 200

const ROAD_ICONS = {
	ROAD_CLEAR: preload("res://assets/icons/facilities/clear_road.svg"),
	ROAD_ROAD: preload("res://assets/icons/facilities/road.svg"),
}

const ROAD_NAMES = {
	ROAD_CLEAR: "Clear roads",
	ROAD_ROAD: "Roads",
}

const ROAD_INFO = {
	ROAD_CLEAR: "Clear roads",
	ROAD_ROAD: "Build roads",
}

const ROAD_CAPACITY = {
	ROAD_CLEAR: 0,
	ROAD_ROAD: 25,
}

const ROAD_KEYS = {
	ROAD_CLEAR: KEY_E,
	ROAD_ROAD: KEY_R,
}

const ROAD_COSTS = {
	ROAD_CLEAR: 0,
	ROAD_ROAD: 5,
}

const ROAD_MAINTENANCE_1000 = {
	ROAD_CLEAR: 0,
	ROAD_ROAD: 250,
}
