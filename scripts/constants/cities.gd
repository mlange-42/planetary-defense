class_name Cities

# Minimum distance for city label visibility
const LABEL_MIN_DIST = 1.4
# Maximum distance for city label visibility
const LABEL_MAX_DIST = 15.0

# Basic growth probability
const CITY_GROWTH_PROB: float = 0.2

# Base cost for extending city radius, see city_growth_cost(...)
const CITY_EXTENSION_COST: int = 25

const INITIAL_CITY_RADIUS: int = 1
const INITIAL_CITY_POP: int = 1
const NO_PRODUCTS_CITY_POP: int = 4

const PRODUCTS_PER_POP: float = 0.5

const UNEMPLOYMENT_NO_GROWTH = 0.25
const UNEMPLOYED_MIGRATION_PROB = 0.05

static func products_demand(pop: int) -> int:
	if pop <= NO_PRODUCTS_CITY_POP:
		return 0
	return int(max(pop * PRODUCTS_PER_POP, 1.0) - 1.0)


static func city_growth_cost(old_radius: int) -> int:
	var rad = (old_radius + 1)
	return int(round(pow(2, rad))) * CITY_EXTENSION_COST


static func city_maintenance(radius: int) -> int:
	return radius * radius * Facilities.FACILITY_MAINTENANCE[Facilities.FAC_CITY]
