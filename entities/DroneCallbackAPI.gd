extends Node

func stop():
	$"../CPU".stop()
	get_parent().invalidate_timers()

func say(text):
	$"../CPU".wait_for_callback()
	get_parent().say(String(text))

func mute():
	$"../CPU".wait_for_callback()
	get_parent().mute()
	
func move_forward():
	$"../CPU".wait_for_callback()
	get_parent().move_forward()
	
func rotate_left():
	$"../CPU".wait_for_callback()
	get_parent().rotate_left()
	
func rotate_right():
	$"../CPU".wait_for_callback()
	get_parent().rotate_right()
	
func get_position():
	return get_parent().get_position()
