extends Control
class_name Gui

var planet: Planet
var states = []

func _ready():
	push("default", {})


func on_planet_hovered(node: int):
	state().on_planet_hovered(node)


func on_planet_clicked(node: int, button: int):
	state().on_planet_clicked(node, button)


func state():
	if states.empty():
		return null
	
	return states[-1]

func push(new_state: String, args: Dictionary):
	var new_scene = load("res://scenes/gui/states/%s.tscn" % new_state).instance()
	
	var old_state = state()
	new_scene.init(self, args)
	self.states.append(new_scene)
	
	if old_state != null:
		self.remove_child(old_state)
		old_state.state_exited()
		
	self.add_child(new_scene)
	new_scene.state_entered()

func pop():
	if states.size() < 2:
		return null
	
	var old_state = states.pop_back()
	self.remove_child(old_state)
	old_state.state_exited()
	
	var new_state = state()
	self.add_child(new_state)
	new_state.state_entered()
