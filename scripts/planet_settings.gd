class_name PlanetSettings


const HEIGHT_CURVES = {
	"continental": preload("res://assets/params/height_curve_continental.tres"),
	"normal": preload("res://assets/params/height_curve_default.tres"),
	"oceanic": preload("res://assets/params/height_curve_oceanic.tres"),
}

const PRECIPITATION_CURVES = {
	"humid": preload("res://assets/params/precipitation_curve_humid.tres"),
	"normal": preload("res://assets/params/linear_curve.tres"),
	"arid": preload("res://assets/params/precipitation_curve_arid.tres"),
}

const TEMPERATURE_CURVES = {
	"cold": preload("res://assets/params/temperature_curve_low.tres"),
	"normal": preload("res://assets/params/linear_curve.tres"),
	"warm": preload("res://assets/params/temperature_curve_high.tres"),
}

const PLANET_SIZES = {
	"tiny": {
		"radius": 2.5,
		"max_height": 0.33,
		"subdivisions": 4,
		"noise_period": 0.9,
		
	},
	"small": {
		"radius": 5,
		"max_height": 0.5,
		"subdivisions": 5,
		"noise_period": 0.8,
	},
	"normal": {
		"radius": 10,
		"max_height": 1.0,
		"subdivisions": 6,
		"noise_period": 0.7,
	},
	"large": {
		"radius": 20,
		"max_height": 2.0,
		"subdivisions": 7,
		"noise_period": 0.5,
	}
}
