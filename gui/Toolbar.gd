extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal open_editor_requested
signal spawn_drone_requested
signal open_drone_manager_requested


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Editor_button_down():
	emit_signal("open_editor_requested")


func _on_Spawn_button_down():
	emit_signal("spawn_drone_requested")


func _on_Drones_button_down():
	emit_signal("open_drone_manager_requested")
