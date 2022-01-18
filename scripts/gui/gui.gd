extends Control
class_name Gui

signal go_to_location(location)

onready var constants: LandUse = $"/root/VegetationLandUse"

onready var stats_bar: StatsBar = $StatsBar
onready var messages: MessageWindow = find_node("MessageWindow")
onready var land_use_info: LandUseInfo = find_node("LandUseInfo")
onready var facility_info: FacilityInfo = find_node("FacilityInfo")
onready var build_info: BuildInfo = find_node("BuildInfo")
onready var info_tabs: TabContainer = find_node("InfoTabs")

onready var inspect_button: Button = find_node("Inspect")

onready var error_container = $ErrorContainer
onready var error_panel: ErrorPanel = $ErrorContainer/ErrorPanel

onready var error_timer = find_node("ErrorTimer")

var mode_buttons: ButtonGroup
var planet: Planet
var states = []

var _current_node: int = -1

func _ready():
	mode_buttons = ButtonGroup.new()
	find_node("Flows").group = mode_buttons
	find_node("Settings").group = mode_buttons
	
	# warning-ignore:return_value_discarded
	stats_bar.connect("next_turn", self, "_on_next_turn")


func init():
	error_container.visible = false
	push("build", {})
	update_messages(true)
	update_facility_info(-1)
	
	stats_bar.set_planet_name(planet.save_name)
	stats_bar.update_commodities(planet)
	stats_bar.update_coverage(planet.space)


func _unhandled_key_input(event: InputEventKey):
	if event.pressed:
		if event.scancode == KEY_S and event.control and not event.shift:
			save_game()
		elif event.scancode == KEY_Q and event.control and not event.shift:
			get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)


func on_planet_entered(node: int):
	_current_node = node
	state().on_planet_entered(node)
	
func on_planet_exited():
	_current_node = -1
	update_land_use_info(-1)
	update_facility_info(-1)
	state().on_planet_exited()

func on_planet_hovered(node: int):
	_current_node = node
	update_land_use_info(node)
	update_facility_info(node)
	state().on_planet_hovered(node)


func on_planet_clicked(node: int, button: int):
	state().on_planet_clicked(node, button)


func update_finances():
	stats_bar.update_finances(planet)


func update_messages(set_visible: bool):
	messages.update_messages(planet.messages)
	if set_visible and not planet.messages.messages.empty():
		messages.visible = true


func update_land_use_info(node: int):
	land_use_info.update_info(planet, constants, node)


func update_facility_info(node):
	if planet.roads.has_facility(node):
		facility_info.update_info(planet.roads.get_facility(node))
	else:
		facility_info.update_info(null)
	info_tabs.current_tab = 0


func update_build_info(type, road_length: int = -1):
	if road_length >= 0:
		build_info.update_info_road(type, road_length)
	else:
		build_info.update_info_facility(type)
	info_tabs.current_tab = 1


func _on_Messages_go_to_pressed(message):
	var loc = planet.planet_data.get_position(message.node)
	go_to(loc)


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
	
	if states.size() == 1:
		for button in mode_buttons.get_buttons():
			button.pressed = false


func pop_all():
	if states.size() < 2:
		return null
	
	var old_state = states.pop_back()
	self.remove_child(old_state)
	old_state.state_exited()
	old_state.queue_free()
	
	while states.size() > 1:
		states.pop_back()
		
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
	error_panel.set_message(message, message_level)
	error_container.visible = true
	error_timer.start()


func log_message(node: int, message: String, message_level: int):
	planet.messages.add_message(node, message, message_level)


func _on_next_turn():
	planet.next_turn()
	update_facility_info(get_current_node())
	state().on_next_turn()
	update_messages(true)
	show_message("Next turn", Consts.MESSAGE_INFO)
	stats_bar.update_commodities(planet)
	stats_bar.update_coverage(planet.space)


func get_current_node():
	return _current_node

func go_to(location: Vector3):
	emit_signal("go_to_location", location)


func get_node_info(node: int):
	if node < 0:
		return "Space"
	
	var veg = planet.planet_data.get_node(node).vegetation_type
	var res_here = planet.resources.resources.get(node, null)
	var fac_here = planet.roads.get_facility(node)
	var text = LandUse.VEG_NAMES[veg]
	if res_here != null:
		text += "\n %s" % Resources.RES_NAMES[res_here[0]]
	if fac_here != null:
		var n = ("C: %s" % fac_here.name) if fac_here is City else fac_here.type
		text += "\n%s" % n
	
	return text


func _on_ErrorTimer_timeout():
	error_container.visible = false


func _on_MainMenu_pressed():
	push("game_menu", {})

func _on_Settings_pressed():
	pop_all()
	push("settings", {})

func _on_Messages_pressed():
	messages.visible = not messages.visible

func _on_Build_pressed():
	pop_all()
	push("build", {})

func _on_Flows_pressed():
	pop_all()
	push("flows", {})
