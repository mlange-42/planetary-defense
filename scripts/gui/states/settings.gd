extends GuiState
class_name SettingsState

onready var invert_zoom: CheckBox = find_node("InvertZoom")
onready var fullscreen: CheckBox = find_node("Fullscreen")
onready var fx_outlines: CheckBox = find_node("FxOutlines")
onready var planet_outlines: CheckBox = find_node("PlanetOutlines")
onready var geometry_outlines: CheckBox = find_node("GeometryOutlines")
onready var msaa: OptionButton = find_node("MSAA")
onready var fxaa: CheckBox = find_node("FXAA")

onready var settings: GameSettings = get_node("/root/Settings")

func _ready():
	msaa.add_item("no MSAA")
	msaa.add_item("2x MSAA")
	msaa.add_item("4x MSAA")
	msaa.add_item("8x MSAA")
	
	invert_zoom.pressed = settings.invert_zoom
	fullscreen.pressed = settings.fullscreen
	msaa.selected = settings.msaa
	fxaa.pressed = settings.fxaa
	fx_outlines.pressed = settings.fx_outlines
	planet_outlines.pressed = settings.planet_outlines
	geometry_outlines.pressed = settings.geometry_outlines


func state_exited():
	apply_settings()


func apply_settings():
	settings.fullscreen = fullscreen.pressed
	settings.invert_zoom = invert_zoom.pressed
	settings.msaa = msaa.selected
	settings.fxaa = fxaa.pressed
	settings.fx_outlines = fx_outlines.pressed
	settings.planet_outlines = planet_outlines.pressed
	settings.geometry_outlines = geometry_outlines.pressed
	
	settings.apply()
	
	settings.save(null)


func _on_OkButton_pressed():
	apply_settings()
	fsm.pop()

func _on_BackButton_pressed():
	apply_settings()
	fsm.pop()
