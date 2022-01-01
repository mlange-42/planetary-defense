extends GuiState
class_name SettingsState


onready var city_labels: CheckBox = find_node("CityLabels")
onready var land_use: CheckBox = find_node("LandUse")
onready var roads: CheckBox = find_node("Roads")


func _ready():
	var cam = get_viewport().get_camera()
	city_labels.set_pressed_no_signal(cam.get_cull_mask_bit(Constants.LAYER_LABELS))
	land_use.set_pressed_no_signal(cam.get_cull_mask_bit(Constants.LAYER_LAND_USE))
	roads.set_pressed_no_signal(cam.get_cull_mask_bit(Constants.LAYER_ROADS))


func _on_visibility_changed(_button_pressed):
	var cam = get_viewport().get_camera()
	cam.set_cull_mask_bit(Constants.LAYER_LABELS, city_labels.pressed)
	cam.set_cull_mask_bit(Constants.LAYER_LAND_USE, land_use.pressed)
	cam.set_cull_mask_bit(Constants.LAYER_ROADS, roads.pressed)


func _on_Back_pressed():
	fsm.pop()


func _on_EnableAllButton_pressed():
	city_labels.pressed = true
	land_use.pressed = true
	roads.pressed = true


func _on_DisableAllButton_pressed():
	city_labels.pressed = false
	land_use.pressed = false
	roads.pressed = false