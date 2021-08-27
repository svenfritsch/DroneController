extends WindowDialog

signal save(path)
signal cancel

func _ready():
	$MarginContainer/VBoxContainer/Input/TextEdit.text = "my_script"

func _on_ButtonSave_down():
	emit_signal("save", "%s%s" % [Globals.SCRIPT_DIR, $MarginContainer/VBoxContainer/Input/TextEdit.text])
	
func _on_ButtonCancel_down():
	emit_signal("cancel")
