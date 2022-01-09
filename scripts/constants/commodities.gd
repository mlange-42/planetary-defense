class_name Commodities

const COMM_FOOD: String = "Food"
const COMM_RESOURCES: String = "Resources"
const COMM_PRODUCTS: String = "Products"

const COMM_ALL = [COMM_FOOD, COMM_RESOURCES, COMM_PRODUCTS]

const COMM_ICONS = {
	COMM_FOOD: preload("res://assets/icons/commodities/food.svg"),
	COMM_RESOURCES: preload("res://assets/icons/commodities/resources.svg"),
	COMM_PRODUCTS: preload("res://assets/icons/commodities/products.svg"),
}
const COMM_ICON_ALL: Texture = preload("res://assets/icons/commodities/all.svg")

const COMM_TAX_RATES = {
	COMM_FOOD: 1,
	COMM_RESOURCES: 1,
	COMM_PRODUCTS: 1,
}
