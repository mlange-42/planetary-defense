extends Control
class_name VisibilityButtons


onready var city_labels: Button = find_node("CityLabels")
onready var land_use: Button = find_node("LandUse")
onready var roads: Button = find_node("Roads")
onready var resources: Button = find_node("Resources")
onready var city_ranges: Button = find_node("CityRanges")
onready var defense_ranges: Button = find_node("DefenseRanges")
onready var events: Button = find_node("Events")


func _ready():
	var cam = get_viewport().get_camera()
	city_labels.set_pressed_no_signal(cam.get_cull_mask_bit(Consts.LAYER_LABELS))
	land_use.set_pressed_no_signal(cam.get_cull_mask_bit(Consts.LAYER_LAND_USE))
	roads.set_pressed_no_signal(cam.get_cull_mask_bit(Consts.LAYER_ROADS))
	resources.set_pressed_no_signal(cam.get_cull_mask_bit(Consts.LAYER_RESOURCES))
	city_ranges.set_pressed_no_signal(cam.get_cull_mask_bit(Consts.LAYER_CITY_RANGES))
	defense_ranges.set_pressed_no_signal(cam.get_cull_mask_bit(Consts.LAYER_DEFENSE_RANGES))
	events.set_pressed_no_signal(cam.get_cull_mask_bit(Consts.LAYER_EVENTS))


func _on_visibility_changed(_button_pressed):
	var cam = get_viewport().get_camera()
	cam.set_cull_mask_bit(Consts.LAYER_LABELS, city_labels.pressed)
	cam.set_cull_mask_bit(Consts.LAYER_LAND_USE, land_use.pressed)
	cam.set_cull_mask_bit(Consts.LAYER_ROADS, roads.pressed)
	cam.set_cull_mask_bit(Consts.LAYER_RESOURCES, resources.pressed)
	cam.set_cull_mask_bit(Consts.LAYER_CITY_RANGES, city_ranges.pressed)
	cam.set_cull_mask_bit(Consts.LAYER_DEFENSE_RANGES, defense_ranges.pressed)
	cam.set_cull_mask_bit(Consts.LAYER_EVENTS, events.pressed)
