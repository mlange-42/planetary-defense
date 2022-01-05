extends Control
class_name Gui

signal go_to_location(location)

onready var constants: LandUse = $"/root/VegetationLandUse"

onready var budget_label = $MarginContainer/PanelContainer/HBoxContainer/BudgetLabel
onready var taxes_label = $MarginContainer/PanelContainer/HBoxContainer/TaxesLabel
onready var maintenance_label = $MarginContainer/PanelContainer/HBoxContainer/MaintenenaceLabel
onready var net_label = $MarginContainer/PanelContainer/HBoxContainer/NetLabel
onready var turn_label = $MarginContainer/PanelContainer/HBoxContainer/TurnLabel

onready var error_container = $ErrorContainer
onready var error_label = find_node("ErrorLabel")
onready var error_timer = find_node("ErrorTimer")

var planet: Planet
var states = []

func init():
	error_container.visible = false
	push("default", {})


func _unhandled_key_input(event: InputEventKey):
	if event.pressed:
		if event.scancode == KEY_S and event.control:
			save_game()
		elif event.scancode == KEY_Q and event.control:
			get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)


func on_planet_entered(node: int):
	state().on_planet_entered(node)
	
func on_planet_exited():
	state().on_planet_exited()

func on_planet_hovered(node: int):
	state().on_planet_hovered(node)


func on_planet_clicked(node: int, button: int):
	state().on_planet_clicked(node, button)


func set_budget_taxes_maintenance(taxes: TaxManager):
	budget_label.text = str(taxes.budget)
	taxes_label.text = str(taxes.taxes)
	maintenance_label.text = "%d (%d+%d+%d+%d)" % [taxes.maintenance, taxes.maintenance_facilities, taxes.maintenance_land_use, taxes.maintenance_roads, taxes.maintenance_transport]
	net_label.text = "%+d" % (taxes.taxes - taxes.maintenance)
	turn_label.text = str(planet.stats.turn())


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
	show_message("Saved game", Consts.MESSAGE_INFO)


func show_message(message: String, message_level: int):
	match message_level:
		Consts.MESSAGE_INFO: error_label.self_modulate = Color.white
		Consts.MESSAGE_WARNING: error_label.self_modulate = Color.yellow
		_: error_label.self_modulate = Color.orange
	
	error_label.text = message
	error_container.visible = true
	error_timer.start()


func log_message(node: int, message: String, message_level: int):
	planet.messages.add_message(node, message, message_level)


func _on_next_turn():
	planet.next_turn()
	state().on_next_turn()
	show_message("Next turn", Consts.MESSAGE_INFO)


func go_to(location: Vector3):
	emit_signal("go_to_location", location)


func get_node_info(node: int):
	if node < 0:
		return "Space"
	
	var veg = planet.planet_data.get_node(node).vegetation_type
	var res_here = planet.resources.resources.get(node, null)
	var fac_here = planet.roads.facilities.get(node, null)
	var text = LandUse.VEG_NAMES[veg]
	if res_here != null:
		text += "\n %s" % Resources.RES_NAMES[res_here[0]]
	if fac_here != null:
		var n = ("C: %s" % fac_here.name) if fac_here is City else fac_here.type
		text += "\n%s" % n
	
	return text


func _on_ErrorTimer_timeout():
	error_container.visible = false
