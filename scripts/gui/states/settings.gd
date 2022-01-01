extends GuiState
class_name SettingsState


onready var city_labels: CheckBox = find_node("CityLabels")
onready var land_use: CheckBox = find_node("LandUse")
onready var roads: CheckBox = find_node("Roads")
onready var resources: CheckBox = find_node("Resources")


func _ready():
	var cam = get_viewport().get_camera()
	city_labels.set_pressed_no_signal(cam.get_cull_mask_bit(Consts.LAYER_LABELS))
	land_use.set_pressed_no_signal(cam.get_cull_mask_bit(Consts.LAYER_LAND_USE))
	roads.set_pressed_no_signal(cam.get_cull_mask_bit(Consts.LAYER_ROADS))
	resources.set_pressed_no_signal(cam.get_cull_mask_bit(Consts.LAYER_RESOURCES))


func _on_visibility_changed(_button_pressed):
	var cam = get_viewport().get_camera()
	cam.set_cull_mask_bit(Consts.LAYER_LABELS, city_labels.pressed)
	cam.set_cull_mask_bit(Consts.LAYER_LAND_USE, land_use.pressed)
	cam.set_cull_mask_bit(Consts.LAYER_ROADS, roads.pressed)
	cam.set_cull_mask_bit(Consts.LAYER_RESOURCES, resources.pressed)


func _on_Back_pressed():
	fsm.pop()

func toggle_all(enable: bool):
	city_labels.pressed = enable
	land_use.pressed = enable
	roads.pressed = enable
	resources.pressed = enable

func _on_EnableAllButton_pressed():
	toggle_all(true)


func _on_DisableAllButton_pressed():
	toggle_all(false)
