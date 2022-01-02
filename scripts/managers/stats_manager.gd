class_name StatsManager

var _turn: int = 0 setget , turn

func update_turn():
	_turn += 1

func turn() -> int:
	return _turn


func save() -> Dictionary:
	return {
		"turn": _turn,
	}

func read(dict: Dictionary):
	_turn = dict["turn"] as int
	
