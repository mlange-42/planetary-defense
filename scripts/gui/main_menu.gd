extends Control


onready var controls: Control = $Controls
onready var name_edit: LineEdit = $Controls/LineEdit
onready var error_label: Label = $Controls/ErrorLabel
onready var progress: Label = $ProgressLabel

onready var file_list: ItemList = $Controls/ItemList

var files: Array

func _ready():
	name_edit.grab_focus()
	
	files = list_saved_games("user://")
	
	if files.empty():
		file_list.visible = false
		$Controls/LoadButton.visible = false
	else:
		for file in files:
			file_list.add_item(file)


func _on_GenerateButton_pressed():
	text_entered(name_edit.text)


func _on_LoadButton_pressed():
	if file_list.is_anything_selected():
		var file = files[file_list.get_selected_items()[0]]
		text_entered(file)
	else:
		error_label.text = "Please select a saved game!"


func text_entered(text: String):
	error_label.text = ""
	if text.empty():
		error_label.text = "Please enter a new or existing planet name!"
		return
	
	if not text.is_valid_filename():
		error_label.text = "Planet name contains invalid characters!"
		return
	
	controls.visible = false
	progress.text = "Loading planet..." if FileUtil.save_path_exists(text, FileUtil.PLANET_EXTENSION) else "Generating planet..."
	progress.visible = true
	
	self.call_deferred("change_scene", text)


func change_scene(name: String):
	yield(get_tree().create_timer(0.1), "timeout")
	
	var root = get_tree().root
	
	var world = load("res://scenes/world.tscn").instance()
	world.planet_params = [PlanetSettings.PLANET_SIZES["small"]]
	world.save_name = name
	
	root.remove_child(self)
	self.call_deferred("free")
	
	root.add_child(world)


func list_saved_games(path: String):
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
