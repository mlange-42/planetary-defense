class_name FileUtil


static func save_path_exists(name: String) -> bool:
	return File.new().file_exists(save_path(name))


static func save_path(name: String) -> String:
	return "%s/%s.csv" % [OS.get_user_data_dir(), name]
