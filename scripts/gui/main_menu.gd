extends Control


onready var controls: Control = $Controls
onready var load_button = find_node("LoadButton")
onready var name_edit: LineEdit = find_node("LineEdit")
onready var error_label: Label = find_node("ErrorLabel")
onready var progress: Label = $ProgressLabel

onready var file_list: ItemList = find_node("FileList")

onready var size_list: OptionButton = find_node("PlanetSizes")
onready var profile_list: OptionButton = find_node("Profiles")
onready var temperature_list: OptionButton = find_node("Temperatures")
onready var humidity_list: OptionButton = find_node("Humidities")
onready var resources_list: OptionButton = find_node("Resources")

onready var options: GameOptions = find_node("Options")

var files: Array

onready var settings: GameSettings = get_node("/root/Settings")

func _ready():
	load_options()
	OS.window_fullscreen = settings.fullscreen
	
	name_edit.grab_focus()
	
	files = list_saved_games()
	
	if files.empty():
		load_button.disabled = true
	else:
		for file in files:
			file_list.add_item(file)
	
	for key in PlanetSettings.PLANET_SIZES:
		size_list.add_item(key)
	size_list.select(2)
	
	for key in PlanetSettings.HEIGHT_CURVES:
		profile_list.add_item(key)
	profile_list.select(1)
	
	for key in PlanetSettings.TEMPERATURE_CURVES:
		temperature_list.add_item(key)
	temperature_list.select(1)
	
	for key in PlanetSettings.PRECIPITATION_CURVES:
		humidity_list.add_item(key)
	humidity_list.select(1)
	
	for key in PlanetSettings.RESOURCE_ABUNDANCE:
		resources_list.add_item(key)
	resources_list.select(2)


func _on_GenerateButton_pressed():
	text_entered(name_edit.text)


func _on_LoadButton_pressed():
	if file_list.is_anything_selected():
		var file = files[file_list.get_selected_items()[0]]
		text_entered(file)
	else:
		error_label.text = "Please select a saved game!"


func _on_QuitButton_pressed():
	get_tree().quit()


func _on_OptionsButton_pressed():
	options.set_options(settings)
	options.visible = true


func _on_options_confirmed():
	save_options()
	OS.window_fullscreen = settings.fullscreen
	options.visible = false


func text_entered(text: String):
	error_label.text = ""
	if text.empty():
		error_label.text = "Please enter a new or existing planet name!"
		return
	
	if not text.is_valid_filename():
		error_label.text = "Planet name contains invalid characters!"
		return
	
	controls.visible = false
	progress.text = ("Loading planet %s..." if FileUtil.save_path_exists(text, FileUtil.PLANET_EXTENSION) \
					else "Generating planet %s...") % text
	progress.visible = true
	
	self.call_deferred("change_scene", text)


func change_scene(name: String):
	yield(get_tree().create_timer(0.1), "timeout")
	
	var root = get_tree().root
	
	var size = size_list.get_item_text(int(max(size_list.selected, 0)))
	var profile = profile_list.get_item_text(int(max(profile_list.selected, 0)))
	var temperature = temperature_list.get_item_text(int(max(temperature_list.selected, 0)))
	var humidity = humidity_list.get_item_text(int(max(humidity_list.selected, 0)))
	var resources = resources_list.get_item_text(int(max(resources_list.selected, 0)))
	
	var world = load("res://scenes/world.tscn").instance()
	world.planet_params = [
		PlanetSettings.PLANET_SIZES[size],
		{
			"height_curve": PlanetSettings.HEIGHT_CURVES[profile],
			"precipitation_curve": PlanetSettings.PRECIPITATION_CURVES[humidity],
			"temperature_curve": PlanetSettings.TEMPERATURE_CURVES[temperature],
			"resource_abundance": PlanetSettings.RESOURCE_ABUNDANCE[resources],
		}
	]
	world.save_name = name
	
	root.remove_child(self)
	self.call_deferred("free")
	
	root.add_child(world)


func list_saved_games():
	var path: String = "user://%s" % Consts.SAVEGAME_DIR
	
	var game_files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	
	var prefix: String = ".%s" % FileUtil.PLANET_EXTENSION
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif file.ends_with(prefix):
			game_files.append(file.substr(0, file.length() - prefix.length()))
	
	dir.list_dir_end()
	return game_files


func save_options():
	settings.save(null)


func load_options():
	settings.read(null)
