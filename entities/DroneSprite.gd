extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var drone = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and not event.is_echo() and event.button_index == BUTTON_LEFT:
		var texture = frames.get_frame("default", 1)
		var pos = position + offset - ( (texture.get_size() / 2.0) if centered else Vector2() ) # added this 2
		if Rect2(pos, texture.get_size()).has_point(event.position): # added this
			drone._on_click()
			get_tree().set_input_as_handled() # if you don't want subsequent input callbacks to respond to this input
