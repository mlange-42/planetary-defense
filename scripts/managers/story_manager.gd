class_name StoryManager

var planet = null
var turn_events: Array = []

var min_pop = 50
var attack_probability = 0.1

# warning-ignore:shadowed_variable
func _init(planet):
	self.planet = planet


func update_turn():
	clear_events()
	
	var cities_pop = _count_cities_pop()
	var _cities = cities_pop[0]
	var pop = cities_pop[1]
	
	if pop < min_pop:
		return
	
	if randf() < attack_probability:
		var new_event = AirAttack.new()
		if new_event.select_target(planet):
			new_event.init(planet)
			var msg = new_event.do_effect(planet)
			new_event.show_effect(planet)
			if msg != null:
				planet.messages.add_message(new_event.node_id, msg, Consts.MESSAGE_ERROR)
			
			turn_events.append(new_event)


func _count_cities_pop():
	var cities = 0
	var pop = 0
	var facilities = planet.roads.facilities
	for node in facilities:
		var fac = facilities[node]
		if fac is City:
			cities += 1
			pop += fac.population()
	
	return [cities, pop]


func clear_events():
	for e in turn_events:
		e.delete(planet)
	
	turn_events.clear()


func save() -> Dictionary:
	var events = []
	
	for e in turn_events:
		events.append(e.save())
	
	return {"events": events}


func read(dict: Dictionary):
	var events = dict["events"]
	
	for e in events:
		var evt = load(e["script"]).new()
		evt.read(e)
		
		evt.init(planet)
		evt.show_effect(planet)
		
		turn_events.append(evt)
