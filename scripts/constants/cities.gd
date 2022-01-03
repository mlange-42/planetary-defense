class_name Cities


const CITY_GROWTH_PROB: float = 0.25

const CITY_EXTENSION_COST: int = 25

const INITIAL_CITY_RADIUS: int = 1
const INITIAL_CITY_POP: int = 1
const NO_PRODUCTS_CITY_POP: int = 3

const PRODUCTS_PER_POP: float = 0.5

static func products_demand(pop: int) -> int:
	if pop <= NO_PRODUCTS_CITY_POP:
		return 0
	return int(max(pop * PRODUCTS_PER_POP, 1.0) - 1.0)


static func city_growth_cost(old_radius: int) -> int:
	var rad = (old_radius + 1)
	return int(round(pow(2, rad))) * CITY_EXTENSION_COST


static func city_maintenance(radius: int) -> int:
	return radius * radius * Facilities.FACILITY_MAINTENANCE[Facilities.FAC_CITY]