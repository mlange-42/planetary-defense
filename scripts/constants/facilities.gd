class_name Facilities


const FAC_CITY: String = "City"
const FAC_PORT: String = "Port"
const FAC_TRAIN_STATION: String = "Train station"
const FAC_AIR_DEFENSE: String = "Air Defense"
const FAC_POWER_PLANT: String = "Power plant"

# Also determines the order of tools
const FACILITY_ICONS = {
	FAC_CITY: preload("res://assets/icons/facilities/city.svg"),
	FAC_PORT: preload("res://assets/icons/facilities/port.svg"),
	FAC_TRAIN_STATION: preload("res://assets/icons/facilities/train_station.svg"),
	FAC_POWER_PLANT: preload("res://assets/icons/facilities/power_plant.svg"),
	FAC_AIR_DEFENSE: preload("res://assets/icons/facilities/air_defense.svg"),
}

const FACILITY_SCENES = {
	FAC_CITY: "res://scenes/objects/city.tscn",
	FAC_PORT: "res://scenes/objects/port.tscn",
	FAC_TRAIN_STATION: "res://scenes/objects/port.tscn",
	FAC_POWER_PLANT: "res://scenes/objects/power_plant.tscn",
	FAC_AIR_DEFENSE: "res://scenes/objects/air_defense.tscn",
}

const FACILITY_POINTERS = {
	FAC_CITY: "res://assets/geom/city.escn",
	FAC_PORT: "res://assets/geom/port.escn",
	FAC_TRAIN_STATION: "res://assets/geom/port.escn",
	FAC_POWER_PLANT: "res://assets/geom/power_plant.escn",
	FAC_AIR_DEFENSE: "res://assets/geom/air_defense.escn",
}

const FACILITY_INFO = {
	FAC_CITY: "Cities house workers and utilize the surrounding land.",
	FAC_PORT: "Required for sea transport and fishery.",
	FAC_TRAIN_STATION: "Connects roads and railways.",
	FAC_POWER_PLANT: "Converts resources to electricity",
	FAC_AIR_DEFENSE: "Defends an area agains air-borne attacks.\n Range increases with elevation.",
}

const FACILITY_RADIUS = {
	FAC_CITY: 1,
	FAC_PORT: 0,
	FAC_TRAIN_STATION: 0,
	FAC_POWER_PLANT: 0,
	FAC_AIR_DEFENSE: 8,
}

const FACILITY_NETWORK_MODES = {
	FAC_CITY: [Network.M_ROADS],
	FAC_PORT: [Network.M_ROADS, Network.M_SEA],
	FAC_TRAIN_STATION: [Network.M_ROADS, Network.M_RAIL],
	FAC_POWER_PLANT: [Network.M_ROADS, Network.M_ELECTRIC],
	FAC_AIR_DEFENSE: [Network.M_ELECTRIC],
}

const FACILITY_RADIUS_FUNC = {
	FAC_CITY: "constant_range",
	FAC_PORT: "constant_range",
	FAC_TRAIN_STATION: "constant_range",
	FAC_POWER_PLANT: "constant_range",
	FAC_AIR_DEFENSE: "air_defense_range",
}

const FACILITY_COSTS = {
	FAC_CITY: 100,
	FAC_PORT: 50,
	FAC_TRAIN_STATION: 200,
	FAC_POWER_PLANT: 100,
	FAC_AIR_DEFENSE: 200,
}

const FACILITY_MAINTENANCE = {
	FAC_CITY: 1,
	FAC_PORT: 3,
	FAC_TRAIN_STATION: 5,
	FAC_POWER_PLANT: 5,
	FAC_AIR_DEFENSE: 8,
}

const FACILITY_SINKS = {
	FAC_CITY: null,
	FAC_PORT: null,
	FAC_TRAIN_STATION: null,
	FAC_POWER_PLANT: null,
	FAC_AIR_DEFENSE: [[Commodities.COMM_ELECTRICITY, 2]],
}

const FACILITY_SOURCES = {
	FAC_CITY: null,
	FAC_PORT: null,
	FAC_TRAIN_STATION: null,
	FAC_POWER_PLANT: null,
	FAC_AIR_DEFENSE: null,
}

const FACILITY_CONVERSIONS = {
	FAC_CITY: null,
	FAC_PORT: null,
	FAC_TRAIN_STATION: null,
	FAC_POWER_PLANT: [[Commodities.COMM_RESOURCES, 1, Commodities.COMM_ELECTRICITY, 1, 5]],
	FAC_AIR_DEFENSE: null,
}

const FACILITY_IN_CITY = {
	FAC_CITY: false,
	FAC_PORT: true,
	FAC_TRAIN_STATION: true,
	FAC_POWER_PLANT: false,
	FAC_AIR_DEFENSE: false,
}

const FACILITY_KEYS = {
	FAC_CITY: KEY_C,
	FAC_PORT: KEY_P,
	FAC_TRAIN_STATION: KEY_S,
	FAC_POWER_PLANT: KEY_T,
	FAC_AIR_DEFENSE: KEY_A,
}

const FACILITY_CAN_BUILD_FUNC = {
	FAC_CITY: "can_build_land",
	FAC_PORT: "can_build_port",
	FAC_TRAIN_STATION: "can_build_land",
	FAC_POWER_PLANT: "can_build_land",
	FAC_AIR_DEFENSE: "can_build_land",
}

class FacilityFunctions:
	func can_build(type, planet_data, node, owner) -> bool:
		return self.call(FACILITY_CAN_BUILD_FUNC[type], planet_data, node, owner)
		
	func calc_range(type, planet_data, node) -> bool:
		return self.call(FACILITY_RADIUS_FUNC[type], planet_data, node, FACILITY_RADIUS[type])
	
	
	func can_build_land(planet_data, node, _owner) -> bool:
		return not planet_data.get_node(node).is_water

	func can_build_port(planet_data, node, _owner) -> bool:
		var nd = planet_data.get_node(node)
		
		if not nd.is_water:
			return false
		
		var neigh = planet_data.get_neighbors(node)
		for n in neigh:
			if not planet_data.get_node(n).is_water:
				return true
		
		return false
	
	
	func constant_range(_planet_data, _node, radius) -> int:
		return radius
	
	
	func air_defense_range(planet_data, node, radius) -> int:
		var nd = planet_data.get_node(node)
		var ele = Consts.elevation(nd.elevation)
		
		if ele < 1000:
			return radius
		elif ele < 2000:
			return int(round(radius * 1.4))
		else:
			return int(round(radius * 1.75))

