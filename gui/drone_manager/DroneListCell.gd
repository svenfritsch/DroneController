extends PanelContainer

var RenameDialog = load("res://gui/drone_manager/ChangeDroneNameDialog.tscn")
onready var name_label = get_node("MarginContainer/HBoxContainer/Label")

func _ready():
	pass # Replace with function body.

func set_name(name: String):
	if name_label:
		name_label.text = name

func _on_Rename_button_down():
	var rename_dialog = RenameDialog.instance()
	self.get_parent().add_child(rename_dialog)
	rename_dialog.show()
