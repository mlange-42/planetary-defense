extends Node
class_name GameSettings

var fullscreen: bool = false
var invert_zoom: bool = false
var msaa: int = 2
var fxaa: bool = false
var fx_outlines: bool = false
var planet_outlines: bool = false
var geometry_outlines: bool = true

func default_path() -> String:
	return "user://%s/options.cfg" % Consts.CONFIG_DIR


func apply():
	OS.window_fullscreen = fullscreen
	
	get_viewport().msaa = msaa
	ProjectSettings.set_setting("rendering/quality/filters/msaa", msaa)
	
	get_viewport().fxaa = fxaa
	ProjectSettings.set_setting("rendering/quality/filters/fxaa", fxaa)
	
	var cam: Camera = get_viewport().get_camera()
	if cam != null and cam.has_node("PostProcess"):
		get_viewport().get_camera().get_node("PostProcess").visible = fx_outlines
	
	if not fx_outlines:
		var mat_veg = preload("res://assets/materials/planet/vegetation.tres")
		mat_veg.next_pass = Materials.PLANET_OUTLINES if planet_outlines else null
		
		var mat_lu = preload("res://assets/materials/planet/land_use.tres")
		mat_lu.next_pass = Materials.LAND_USE_OUTLINES if geometry_outlines else null
		var mat_fac = preload("res://assets/materials/planet/facilities.tres")
		mat_fac.next_pass = Materials.FACILITIES_OUTLINES if geometry_outlines else null


func save(path):
	if path == null:
		path = default_path()
	
	var config = ConfigFile.new()
	
	config.set_value("Controls", "invert_zoom", invert_zoom)
	config.set_value("Graphics", "fullscreen", fullscreen)
	config.set_value("Graphics", "msaa", msaa)
	config.set_value("Graphics", "fxaa", fxaa)
	config.set_value("Graphics", "fx_outlines", fx_outlines)
	config.set_value("Graphics", "planet_outlines", planet_outlines)
	config.set_value("Graphics", "geometry_outlines", geometry_outlines)
	
	FileUtil.create_user_dir(Consts.CONFIG_DIR)
	
	config.save(path)


func read(path):
	if path == null:
		path = default_path()
	
	var config = ConfigFile.new()
	var err = config.load(path)
	
	if err == OK:
		invert_zoom = config.get_value("Controls", "invert_zoom", false)
		fullscreen = config.get_value("Graphics", "fullscreen", false)
		msaa = config.get_value("Graphics", "msaa", 2)
		fxaa = config.get_value("Graphics", "fxaa", false)
		fx_outlines = config.get_value("Graphics", "fx_outlines", false)
		planet_outlines = config.get_value("Graphics", "planet_outlines", false)
		geometry_outlines = config.get_value("Graphics", "geometry_outlines", true)
	else:
		save(path)
