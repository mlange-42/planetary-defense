class_name MathUtil


static func round_random(value: float, r: float) -> int:
	var int_value = int(value)
	var rem = value - int_value
	if rem == 0 or r > rem:
		return int_value
	
	return int_value + 1
