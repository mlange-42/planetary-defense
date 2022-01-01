class_name FileUtil


const PLANET_EXTENSION = "planet"
const GAME_EXTENSION = "game"


static func save_path_exists(name: String, ext: String) -> bool:
	return File.new().file_exists(save_path(name, ext))


static func save_path(name: String, ext: String) -> String:
	return "%s/%s/%s.%s" % [OS.get_user_data_dir(), Consts.SAVEGAME_DIR, name,ext]


static func create_user_dir(directory: String):
	var dir = Directory.new()
	dir.open("user://")
	dir.make_dir(directory)
	
