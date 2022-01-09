extends Node
class_name GameSettings

var fullscreen: bool = false
var invert_zoom: bool = false

func default_path() -> String:
	return "user://%s/options.cfg" % Consts.CONFIG_DIR


func save(path):
	if path == null:
		path = default_path()
	
	var config = ConfigFile.new()
	
	config.set_value("Graphics", "fullscreen", fullscreen)
	config.set_value("Controls", "invert_zoom", invert_zoom)
	
	FileUtil.create_user_dir(Consts.CONFIG_DIR)
	
	config.save(path)


func read(path):
	if path == null:
		path = default_path()
	
	var config = ConfigFile.new()
	var err = config.load(path)
	
	if err == OK:
		fullscreen = config.get_value("Graphics", "fullscreen", false)
		invert_zoom = config.get_value("Controls", "invert_zoom", false)
	else:
		save(path)
