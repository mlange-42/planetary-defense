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

const FACILITY_INFO = {
	FAC_CITY: "A city",
	FAC_PORT: "Required for sea transport and fishery",
	FAC_AIR_DEFENSE: "Defends an area agains sir-borne attacks",
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
	FAC_AIR_DEFENSE: 250,
#	FAC_MISSILE_BASE: 500,
}

const FACILITY_MAINTENANCE = {
	FAC_CITY: 1,
	FAC_PORT: 5,
	FAC_AIR_DEFENSE: 10,
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
