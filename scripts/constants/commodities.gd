class_name Commodities

const COMM_FOOD: int = 0
const COMM_RESOURCES: int = 1
const COMM_PRODUCTS: int = 2
const COMM_ELECTRICITY: int = 3

const COMM_ALL = [COMM_FOOD, COMM_RESOURCES, COMM_PRODUCTS, COMM_ELECTRICITY]

const COMM_NAMES = {
	COMM_FOOD: "Food",
	COMM_RESOURCES: "Resources",
	COMM_PRODUCTS: "Products",
	COMM_ELECTRICITY: "Electricity",
}

const COMM_ICONS = {
	COMM_FOOD: preload("res://assets/icons/commodities/food.svg"),
	COMM_RESOURCES: preload("res://assets/icons/commodities/resources.svg"),
	COMM_PRODUCTS: preload("res://assets/icons/commodities/products.svg"),
	COMM_ELECTRICITY: preload("res://assets/icons/commodities/electricity.svg"),
}
const COMM_ICON_ALL: Texture = preload("res://assets/icons/commodities/all.svg")

const COMM_COLORS = {
	COMM_FOOD: Color.orange,
	COMM_RESOURCES: Color.green,
	COMM_PRODUCTS: Color.lightblue,
	COMM_ELECTRICITY: Color.cyan,
}

const COMM_TAX_RATES = {
	COMM_FOOD: 1,
	COMM_RESOURCES: 1,
	COMM_PRODUCTS: 1,
	COMM_ELECTRICITY: 1,
}

const COMM_NETWORK_MODE = {
	COMM_FOOD: Network.M_ROADS,
	COMM_RESOURCES: Network.M_ROADS,
	COMM_PRODUCTS: Network.M_ROADS,
	COMM_ELECTRICITY: Network.M_ELECTRIC,
}

static func to_mode_id(id: int, comm: int) -> int:
	var mode = COMM_NETWORK_MODE[comm]
	return Network.to_mode_id(id, mode)


const _int_array = [0, 0, 0, 0]

static func create_int_array() -> Array:
	var arr: Array = []
	arr.append_array(_int_array)
	return arr
