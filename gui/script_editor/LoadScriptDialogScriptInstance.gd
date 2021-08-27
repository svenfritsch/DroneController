extends MarginContainer

signal selected(name)

func _ready():
	$Button.connect("button_down", self, "_on_select")

func set_script_name(name: String):
	$Button.text = name
	
func get_script_name() -> String:
	return $Button.text
	
func _on_select():
	emit_signal("selected", get_script_name())
	

