class_name StatsManager

var _turn: int = 0 setget , turn

var production: Array = []
var potential_production: Array = []
var population: Array = []
var unemployed: Array = []
var taxes: Array = []
var maintenance: Array = []
var income: Array = []


func _init():
	for _c in Commodities.COMM_ALL:
		production.append([])
		potential_production.append([])


func update_turn():
	_turn += 1

func turn() -> int:
	return _turn

func update_data(planet):
	add_production(planet.roads.total_flows)
	add_pot_production(planet.roads.total_sources)
	
	var pop = 0
	var free = 0
	var fac = planet.roads.facilities()
	for node in fac:
		var f = fac[node]
		if not f is City:
			continue
		pop += f.population()
		free += f.workers()
	
	_add_value(population, pop)
	_add_value(unemployed, free)
	
	_add_value(taxes, planet.taxes.taxes)
	_add_value(maintenance, planet.taxes.maintenance)
	_add_value(income, planet.taxes.taxes - planet.taxes.maintenance)


func add_production(values: Array):
	for i in range(Commodities.COMM_ALL.size()):
		_add_value(production[i], values[i])


func add_pot_production(values: Array):
	for i in range(Commodities.COMM_ALL.size()):
		_add_value(potential_production[i], values[i])


static func _add_value(target: Array, val):
	if not target.empty():
		var prev = target[-1]
		if prev[0] == val:
			prev[1] += 1
			return
	target.append([val, 1])


static func unfold(values) -> Array:
	var res = []
	for pair in values:
		for _i in range(pair[1]):
			res.append(pair[0])
	
	return res


func save() -> Dictionary:
	return {
		"turn": _turn,
		"production": production,
		"pot_production": potential_production,
		"population": population,
		"unemployed": unemployed,
		"taxes": taxes,
		"maintenance": maintenance,
		"income": income,
	}

func read(dict: Dictionary):
	_turn = dict["turn"] as int

	var pr = dict["production"]
	for i in pr.size():
		production[i] = _decode_packed_array(pr[i])

	pr = dict["pot_production"]
	for i in pr.size():
		potential_production[i] = _decode_packed_array(pr[i])
	
	population = _decode_packed_array(dict["population"])
	unemployed = _decode_packed_array(dict["unemployed"])
	taxes = _decode_packed_array(dict["taxes"])
	maintenance = _decode_packed_array(dict["maintenance"])
	income = _decode_packed_array(dict["income"])


func _decode_packed_array(arr: Array) -> Array:
	var res = []
	for i in arr.size():
		res.append([arr[i][0] as int, arr[i][1] as int])
	return res

func _decode_array(arr: Array) -> Array:
	var res = []
	for i in arr.size():
		res.append(arr[i] as int)
	return res
