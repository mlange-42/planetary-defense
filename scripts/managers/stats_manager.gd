class_name StatsManager

var _turn: int = 0 setget , turn

var production: Array
var potential_production: Array


func _init():
	production = []
	potential_production = []
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
	}

func read(dict: Dictionary):
	_turn = dict["turn"] as int
	
	if dict.has("production"):
		var pr = dict["production"]
		for i in pr.size():
			var comm = pr[i]
			for j in comm.size():
				production[i].append([comm[j][0] as int, comm[j][1] as int])
	
	if dict.has("pot_production"):
		var pr = dict["pot_production"]
		for i in pr.size():
			var comm = pr[i]
			for j in comm.size():
				potential_production[i].append([comm[j][0] as int, comm[j][1] as int])
