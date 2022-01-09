extends Node
class_name GameSettings

var fullscreen: bool = false
var invert_mouse: bool = false

func save(path: String):
	var config = ConfigFile.new()
	config.set_value("Graphics", "fullscreen", fullscreen)
	
	config.set_value("Controls", "invert_mouse", fullscreen)
	
	FileUtil.create_user_dir(Consts.CONFIG_DIR)
	
	config.save(path)


func read(path: String):
	var config = ConfigFile.new()
	var err = config.load(path)
	
	if err == OK:
		fullscreen = config.get_value("Graphics", "fullscreen")
		invert_mouse = config.get_value("Controls", "invert_mouse")
	else:
		save(path)
