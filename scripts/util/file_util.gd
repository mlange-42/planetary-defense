class_name FileUtil


static func save_path_exists(name: String, ext: String) -> bool:
	return File.new().file_exists(save_path(name, ext))


static func save_path(name: String, ext: String) -> String:
	return "%s/%s.%s" % [OS.get_user_data_dir(), name,ext]
