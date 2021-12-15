class_name Colors

static func heat_map(value: float) -> Color:
	if value < 0.5:
		return Color.red.linear_interpolate(Color.yellow, value * 2)
	else:
		return Color.yellow.linear_interpolate(Color.green, (value - 0.5) * 2)
