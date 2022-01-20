extends Node
class_name GameSettings

var fullscreen: bool = false
var invert_zoom: bool = false
var msaa: int = 2
var fxaa: bool = false
var outlines: bool = false

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
		get_viewport().get_camera().get_node("PostProcess").visible = outlines


func save(path):
	if path == null:
		path = default_path()
	
	var config = ConfigFile.new()
	
	config.set_value("Controls", "invert_zoom", invert_zoom)
	config.set_value("Graphics", "fullscreen", fullscreen)
	config.set_value("Graphics", "msaa", msaa)
	config.set_value("Graphics", "fxaa", fxaa)
	config.set_value("Graphics", "outlines", outlines)
	
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
		outlines = config.get_value("Graphics", "outlines", false)
	else:
		save(path)
