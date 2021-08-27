extends Node2D

onready var editor = get_node("UI/Control/CodeEditorWindow")
onready var drone_controller = get_node("World/DroneController")
onready var code_editor = get_node("UI/Control/CodeEditorWindow/VBoxContainer/ScriptEdit")
onready var drone_manager = get_node("UI/Control/DroneManagerWindow")

# Called when the node enters the scene tree for the first time.
func _ready():
	drone_manager.drone_controller = drone_controller
	print(OS.get_user_data_dir())

func _on_Editor_Button_pressed():
	editor.popup_centered()


func _on_Toolbar_open_editor_requested():
	editor.show()


func _on_Toolbar_open_drone_manager_requested():
	drone_manager.setup()
	drone_manager.show()
