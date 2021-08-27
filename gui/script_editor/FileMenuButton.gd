extends MenuButton

var popup

export(NodePath) var text_edit_path

var save_button_text = "save"
var load_button_text = "load"

var LoadScriptDialog = load("res://gui/LoadScriptDialog.tscn")
var SaveScriptDialog = load("res://gui/SaveScriptDialog.tscn")

func _ready():
	popup = get_popup()
	
	popup.add_item(save_button_text)
	popup.add_separator()
	popup.add_item(load_button_text)
	
	popup.connect("id_pressed", self, "_on_item_pressed")
	
func _on_script_save(path: String):
	print("Save script at %s" % path)
	
	var file = File.new()
	file.open("%s.txt" % path, File.WRITE)
	file.store_string(get_node(text_edit_path).text)
	file.close()
	
func _on_save():
	var dialog = SaveScriptDialog.instance()
	
	dialog.connect("save", self, "_on_script_save")
	
	self.get_parent().add_child(dialog)
	
	dialog.popup_centered()
	
func _on_script_load(path: String):
	print("Load script at %s" % path)
	
	var file = File.new()
	file.open("%s" % path, File.READ)
	var content = file.get_as_text()
	file.close()
	
	get_node(text_edit_path).text = content
	
func _on_load():
	var dialog = LoadScriptDialog.instance()
	
	dialog.connect("load_script", self, "_on_script_load")
	
	self.get_parent().add_child(dialog)
	
	dialog.popup_centered()

func _on_item_pressed(ID):
	match popup.get_item_text(ID):
		save_button_text:
			_on_save()
		load_button_text:
			_on_load()
