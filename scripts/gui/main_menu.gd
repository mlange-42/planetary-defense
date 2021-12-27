extends Control


onready var controls: Control = $Controls
onready var name_edit: LineEdit = $Controls/LineEdit
onready var error_label: Label = $Controls/ErrorLabel
onready var progress: Label = $ProgressLabel


func _ready():
	name_edit.grab_focus()


func _on_OkButton_pressed():
	text_entered(name_edit.text)


func text_entered(text: String):
	error_label.text = ""
	if text.empty():
		error_label.text = "Please enter a new or existing planet name!"
		return
	
	if not text.is_valid_filename():
		error_label.text = "Planet name contains invalid characters!"
		return
	
	controls.visible = false
	progress.text = "Loading planet..." if FileUtil.save_path_exists(text) else "Generating planet..."
	progress.visible = true
	
	self.call_deferred("change_scene", text)


func change_scene(name: String):
	yield(get_tree().create_timer(0.1), "timeout")
	
	var root = get_tree().root
	
	var world = load("res://scenes/world.tscn").instance()
	world.save_name = name
	
	root.remove_child(self)
	self.call_deferred("free")
	
	root.add_child(world)
