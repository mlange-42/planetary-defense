extends Control
class_name Gui

onready var constants: Constants = $"/root/GameConstants"

onready var budget_label = $MarginContainer/PanelContainer/HBoxContainer/BudgetLabel
onready var taxes_label = $MarginContainer/PanelContainer/HBoxContainer/TaxesLabel
onready var maintenance_label = $MarginContainer/PanelContainer/HBoxContainer/MaintenenaceLabel
onready var net_label = $MarginContainer/PanelContainer/HBoxContainer/NetLabel

onready var error_container = $ErrorContainer
onready var error_label = find_node("ErrorLabel")
onready var error_timer = find_node("ErrorTimer")

var planet: Planet
var states = []

func _ready():
	error_container.visible = false
	push("default", {})


func _unhandled_key_input(event: InputEventKey):
	if event.pressed:
		if event.scancode == KEY_S and event.control:
			save_game()
		elif event.scancode == KEY_Q and event.control:
			get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)


func on_planet_hovered(node: int):
	state().on_planet_hovered(node)


func on_planet_clicked(node: int, button: int):
	state().on_planet_clicked(node, button)


func set_budget_taxes_maintenance(taxes: TaxManager):
	budget_label.text = str(taxes.budget)
	taxes_label.text = str(taxes.taxes)
	maintenance_label.text = "%d (%d+%d)" % [taxes.maintenance, taxes.maintenance_roads, taxes.maintenance_transport]
	net_label.text = "%+d" % (taxes.taxes - taxes.maintenance)


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
	old_state.queue_free()
	
	var new_state = state()
	self.add_child(new_state)
	new_state.state_entered()


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if state().get_class() != "QuitDialog":
			call_deferred("push", "quit_dialog", {})


func save_game():
	planet.save_game()
	show_message("Saved game")


func show_message(message: String):
	error_label.text = message
	error_container.visible = true
	error_timer.start()


func _on_ErrorTimer_timeout():
	error_container.visible = false
