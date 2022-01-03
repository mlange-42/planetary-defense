class_name StoryManager

var planet = null
var turn_events: Array = []


# warning-ignore:shadowed_variable
func _init(planet):
	self.planet = planet


func update_turn():
	clear_events()
	
	var new_event = AirAttack.new()
	if new_event.select_target(planet):
		new_event.init(planet)
		var msg = new_event.do_effect(planet)
		new_event.show_effect(planet)
		if msg != null:
			planet.messages.add_message(new_event.node_id, msg, Consts.MESSAGE_ERROR)
		
		turn_events.append(new_event)


func clear_events():
	for e in turn_events:
		e.delete(planet)


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
