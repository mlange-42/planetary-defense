class_name Facilities


const FAC_CITY: String = "City"
const FAC_PORT: String = "Port"
const FAC_AIR_DEFENSE: String = "Air Defense"
#const FAC_MISSILE_BASE: String = "Missile Base"

const FACILITY_SCENES = {
	FAC_CITY: "res://scenes/objects/city.tscn",
	FAC_PORT: "res://scenes/objects/port.tscn",
	FAC_AIR_DEFENSE: "res://scenes/objects/air_defense.tscn",
#	FAC_MISSILE_BASE: "res://scenes/objects/missile_base.tscn",
}

const FACILITY_POINTERS = {
	FAC_CITY: "res://assets/geom/city.escn",
	FAC_PORT: "res://assets/geom/port.escn",
	FAC_AIR_DEFENSE: "res://assets/geom/air_defense.escn",
#	FAC_MISSILE_BASE: "res://assets/geom/missile_base.escn",
}

const FACILITY_ICONS = {
	FAC_CITY: preload("res://assets/icons/facilities/city.svg"),
	FAC_PORT: preload("res://assets/icons/facilities/port.svg"),
	FAC_AIR_DEFENSE: preload("res://assets/icons/facilities/air_defense.svg"),
#	FAC_MISSILE_BASE: preload("res://assets/icons/gui/missile_base.svg",
}

const FACILITY_INFO = {
	FAC_CITY: "A city",
	FAC_PORT: "Required for sea transport and fishery",
	FAC_AIR_DEFENSE: "Defends an area agains air-borne attacks",
#	FAC_MISSILE_BASE: "Fires missiles against orbital targets",
}

const FACILITY_RADIUS = {
	FAC_CITY: 1,
	FAC_PORT: 0,
	FAC_AIR_DEFENSE: 8,
#	FAC_MISSILE_BASE: 0,
}

const FACILITY_COSTS = {
	FAC_CITY: 100,
	FAC_PORT: 50,
	FAC_AIR_DEFENSE: 200,
#	FAC_MISSILE_BASE: 500,
}

const FACILITY_MAINTENANCE = {
	FAC_CITY: 1,
	FAC_PORT: 3,
	FAC_AIR_DEFENSE: 8,
#	FAC_MISSILE_BASE: 25,
}

const FACILITY_SINKS = {
	FAC_CITY: null,
	FAC_PORT: null,
	FAC_AIR_DEFENSE: [[Commodities.COMM_PRODUCTS, 2]],
#	FAC_MISSILE_BASE: null,
}

const FACILITY_IN_CITY = {
	FAC_CITY: false,
	FAC_PORT: true,
	FAC_AIR_DEFENSE: false,
#	FAC_MISSILE_BASE: false,
}

const FACILITY_KEYS = {
	FAC_CITY: KEY_C,
	FAC_PORT: KEY_P,
	FAC_AIR_DEFENSE: KEY_A,
#	FAC_MISSILE_BASE: KEY_M,
}

const FACILITY_CAN_BUILD_FUNC = {
	FAC_CITY: "can_build_land",
	FAC_PORT: "can_build_port",
	FAC_AIR_DEFENSE: "can_build_land",
#	FAC_MISSILE_BASE: KEY_M,
}

class FacilityFunctions:
	func can_build_land(planet_data, node) -> bool:
		return not planet_data.get_node(node).is_water

	func can_build_port(planet_data, node) -> bool:
		var nd = planet_data.get_node(node)
		
		if not nd.is_water:
			return false
		
		var neigh = planet_data.get_neighbors(node)
		for n in neigh:
			if not planet_data.get_node(n).is_water:
				return true
		
		return false
