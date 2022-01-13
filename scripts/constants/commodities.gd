class_name Commodities

const COMM_FOOD: String = "Food"
const COMM_RESOURCES: String = "Resources"
const COMM_PRODUCTS: String = "Products"
const COMM_ELECTRICITY: String = "Electricity"

const COMM_ALL = [COMM_FOOD, COMM_RESOURCES, COMM_PRODUCTS, COMM_ELECTRICITY]

const COMM_ICONS = {
	COMM_FOOD: preload("res://assets/icons/commodities/food.svg"),
	COMM_RESOURCES: preload("res://assets/icons/commodities/resources.svg"),
	COMM_PRODUCTS: preload("res://assets/icons/commodities/products.svg"),
	COMM_ELECTRICITY: preload("res://assets/icons/commodities/electricity.svg"),
}

const COMM_ICON_ALL: Texture = preload("res://assets/icons/commodities/all.svg")

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

static func to_mode_id(id: int, comm: String) -> int:
	var mode = COMM_NETWORK_MODE[comm]
	return Network.to_mode_id(id, mode)
