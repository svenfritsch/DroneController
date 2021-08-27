extends WindowDialog

var ScriptInstanceGUIElement = load("res://gui/LoadScriptDialogScriptInstance.tscn")

signal load_script(path)
signal cancel

var selected_script

func _list_files():
	var files = []
	var dir = Directory.new()
	if dir.open(Globals.SCRIPT_DIR) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
			elif file_name.begins_with("."):
				pass
			else:
				files.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
		
	return files


# Called when the node enters the scene tree for the first time.
func _ready():
	for file in _list_files():
		var f_gui = ScriptInstanceGUIElement.instance()
		f_gui.set_script_name(file)
		f_gui.connect("selected", self, "_on_script_select")
		$MarginContainer/VBoxContainer/PanelContainer/ScrollContainer/VBoxContainer.add_child(
			f_gui
		)

func _on_script_select(name: String):
	selected_script = name

func _on_ButtonCancel_down():
	emit_signal("cancel")

func _on_ButtonLoad_down():
	emit_signal("load_script", "%s%s" % [Globals.SCRIPT_DIR, selected_script])
