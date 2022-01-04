extends GuiState
class_name EditCityState

onready var city_text: RichTextLabel = find_node("CityText")
onready var node_text: RichTextLabel = $InfoContainer/VBoxContainer/NodePanel/NodeText

onready var sliders = {
	Commodities.COMM_ALL[0]: $Margin/EditControls/WeightPanel/WeightControls/FoodSlider,
	Commodities.COMM_ALL[1]: $Margin/EditControls/WeightPanel/WeightControls/ResourcesSlider,
	Commodities.COMM_ALL[2]: $Margin/EditControls/WeightPanel/WeightControls/ProductsSlider,
}
onready var auto_assign: CheckBox = $Margin/EditControls/WeightPanel/WeightControls/AutoAssignCheckBox
onready var weights_display: Label = $Margin/EditControls/WeightPanel/WeightControls/WeightsDisplay

onready var grow_button: Button = find_node("GrowButton") 

onready var container: Container = find_node("CityInfoContainer")

var city_node: int
var city: City
var button_group: ButtonGroup

var infos = {}

func init(the_fsm: Gui, args: Dictionary):
	.init(the_fsm, args)
	city_node = args["node"]
	city = fsm.planet.roads.get_facility(city_node) as City
	
	var buttons: Container = $Margin/EditControls/Buttons/LuPanel/LuButtons
	button_group = ButtonGroup.new()
	for lu in LandUse.LU_NAMES:
		var button := LandUseButton.new()
		button.land_use = lu
		button.text = LandUse.LU_NAMES[lu]
		button.group = button_group
		
		var evt = InputEventKey.new()
		evt.pressed = true
		evt.scancode = LandUse.LU_KEYS[lu]
		button.shortcut = ShortCut.new()
		button.shortcut.shortcut = evt
		
		buttons.add_child(button)
	
	var fac_buttons: Container = $Margin/EditControls/Buttons/FacilityPanel/FacilityButtons
	for fac in Facilities.FACILITY_IN_CITY:
		if Facilities.FACILITY_IN_CITY[fac]:
			var button := FacilityButton.new()
			button.facility = fac
			button.text = fac
			button.group = button_group
			
			var evt = InputEventKey.new()
			evt.pressed = true
			evt.scancode = Facilities.FACILITY_KEYS[fac]
			button.shortcut = ShortCut.new()
			button.shortcut.shortcut = evt
			
			fac_buttons.add_child(button)


func _ready():
	for comm in Commodities.COMM_ALL:
		var info: CityProductionInfo = preload("res://scenes/gui/states/city/city_production_info.tscn").instance()
		info.set_commodity(comm)
		infos[comm] = info
		container.add_child(info)


func state_entered():
	auto_assign.pressed = city.auto_assign_workers
	for i in range(city.commodity_weights.size()):
		sliders[Commodities.COMM_ALL[i]].value = city.commodity_weights[i]
	
	update_city_info()
	update_weights_display()


func state_exited():
	city.auto_assign_workers = auto_assign.pressed
	for i in range(city.commodity_weights.size()):
		city.commodity_weights[i] = sliders[Commodities.COMM_ALL[i]].value


func update_city_info():
	city_text.text = "%s (%d/%d workers)" % [city.name, city.workers(), city.population()]
	for comm in Commodities.COMM_ALL:
		var flows = city.flows.get(comm, [0, 0])
		var pot_source = 0
		for key in city.conversions:
			if key[1] == comm:
				var conv = city.conversions[key]
				pot_source += city.sinks.get(key[0], 0) * conv[1] / conv[0]
		
		infos[comm].set_values(city.sources.get(comm, 0) + pot_source, flows[0], flows[1], city.sinks.get(comm, 0))
	
	grow_button.hint_tooltip = "Grow city radius.\n Cost: %d\n Maintenance: %d->%d" \
			% [Cities.city_growth_cost(city.radius), Cities.city_maintenance(city.radius), Cities.city_maintenance(city.radius + 1)]


func update_node_info(node: int):
	if node < 0:
		node_text.bbcode_text = ""
		return
	
	var lu_here = city.land_use.get(node, 0)
	var veg = fsm.planet.planet_data.get_node(node).vegetation_type
	var res_here = fsm.planet.resources.resources.get(node, null)
	
	var res_str = "" if res_here == null else (" - %s (%s)" % [Resources.RES_NAMES[res_here[0]], res_here[1]])
	
	var text: String = "%s%s\n" % [LandUse.VEG_NAMES[veg], res_str]
	for lut in fsm.constants.LU_MAPPING:
		var lu: Dictionary = fsm.constants.LU_MAPPING[lut]
		if veg in lu:
			if lu[veg] == null:
				continue
			var prod: LandUse.VegLandUse = lu[veg]
			var prod_string = "" if prod.source == null else (" %2d %s" % [prod.source.amount, prod.source.commodity])
			var line = " %-10s%s" % [LandUse.LU_NAMES[lut], prod_string]
			if lut == lu_here:
				line = "[u]%s[/u]" % line
			text += line + "\n"
	
	if res_here != null:
		var res_id = res_here[0]
		for lut in fsm.constants.LU_RESOURCES:
			var res: Dictionary = fsm.constants.LU_RESOURCES[lut]
			var lu: Dictionary = fsm.constants.LU_MAPPING[lut]
			if res.has(res_here[0]) and lu.has(veg):
				var prod: LandUse.VegLandUse = res[res_id]
				var prod_string = "" if prod.source == null else (" %2d %s" % [prod.source.amount, prod.source.commodity])
				var line = " %-10s%s" % [LandUse.LU_NAMES[lut], prod_string]
				if lut == lu_here:
					line = "[u]%s[/u]" % line
				text += line + "\n"
	
	node_text.bbcode_text = text.substr(0, text.length()-1)


func update_weights_display():
	var sum = 0
	var values = []
	for comm in sliders:
		var v = sliders[comm].value
		values.append(v)
		sum += v
	
	var text = ""
	for i in range(values.size()):
		var v = round(100 * ((values[i] / sum) if sum > 0 else (1.0 / values.size())))
		text += "%d%%" % v
		if i < values.size()-1:
			text += "/"
	
	weights_display.text = text


func get_land_use_tool():
	var button = button_group.get_pressed_button()
	if button == null or not button is LandUseButton:
		return null
	else:
		return button.land_use


func get_facility_tool():
	var button = button_group.get_pressed_button()
	if button == null or not button is FacilityButton:
		return null
	else:
		return button.facility


func _on_weights_changed(_value: float):
	update_weights_display()


func _on_Back_pressed():
	fsm.pop()


func on_planet_hovered(node: int):
	if not node in city.cells:
		update_node_info(-1)
		return
	
	update_node_info(node)


func on_planet_clicked(node: int, button: int):
	if button == BUTTON_LEFT:
		var facility: Facility = fsm.planet.get_facility(node)
		if facility != null and facility is City and facility != city:
			fsm.pop()
			fsm.push("edit_city", {"node": node})
			return
	
	var curr_tool = get_land_use_tool()
	if curr_tool != null:
		if button == BUTTON_LEFT:
			# warning-ignore:return_value_discarded
			var err = fsm.planet.builder.set_land_use(city, node, curr_tool)
			if err != null:
				fsm.show_message(err, Consts.MESSAGE_ERROR)
		elif button == BUTTON_RIGHT:
			# warning-ignore:return_value_discarded
			var err = fsm.planet.builder.set_land_use(city, node, LandUse.LU_NONE)
			if err != null:
				fsm.show_message(err, Consts.MESSAGE_ERROR)
		update_city_info()
	else:
		if button == BUTTON_LEFT:
			curr_tool = get_facility_tool()
			if curr_tool != null:
				var fac_err = fsm.planet.add_facility(curr_tool, node, curr_tool)
				if fac_err[0] != null:
					fac_err[0].city_node_id = city.node_id
					city.add_facility(node, fac_err[0])
				else:
					fsm.show_message(fac_err[1], Consts.MESSAGE_ERROR)


func _on_GrowButton_pressed():
	var err = fsm.planet.grow_city(city)
	if err == null:
		update_city_info()
	else:
		fsm.show_message(err, Consts.MESSAGE_ERROR)
