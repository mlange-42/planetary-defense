class_name Cities


const CITY_GROWTH_PROB: float = 0.333

const INITIAL_CITY_RADIUS: int = 2
const INITIAL_CITY_POP: int = 1
const NO_PRODUCTS_CITY_POP: int = 3

const PRODUCTS_PER_POP: float = 0.5

static func products_demand(pop: int) -> int:
	if pop <= NO_PRODUCTS_CITY_POP:
		return 0
	return int(max(pop * PRODUCTS_PER_POP, 1.0) - 1.0)
