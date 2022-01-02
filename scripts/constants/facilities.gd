class_name Facilities


const FAC_CITY: String = "City"
const FAC_PORT: String = "Port"

const FACILITY_SCENES = {
	FAC_CITY: "res://scenes/objects/city.tscn",
	FAC_PORT: "res://scenes/objects/port.tscn",
}

const FACILITY_INFO = {
	FAC_CITY: "A city",
	FAC_PORT: "Required for sea transport and fishery",
}

const FACILITY_COSTS = {
	FAC_CITY: 100,
	FAC_PORT: 50,
}

const FACILITY_MAINTENANCE = {
	FAC_CITY: 1,
	FAC_PORT: 5,
}

const FACILITY_IN_CITY = {
	FAC_CITY: false,
	FAC_PORT: true,
}

const FACILITY_KEYS = {
	FAC_CITY: KEY_C,
	FAC_PORT: KEY_P,
}
