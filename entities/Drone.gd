extends Node

onready var grid = self.get_parent().get_parent()

var orientation = Vector2(0, -1)

var max_health = 20
var health = max_health

var max_energy
var energy = max_energy

signal selected(drone)

# Called when the node enters the scene tree for the first time.
func _ready():
	$CPU.magic_variables["blocked"] = funcref(self, "get_is_blocked")
	
	var _cpu_connect_stopping = $CPU.connect("stopping", self, "_invalidate_timers")
	
	$Sprite.play()
	
	
# MARK: UI events
func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == 1:
		emit_signal("selected", self)
		
func _on_Area2D_mouse_entered():
	$SelectionBorder.show()

func _on_Area2D_mouse_exited():
	$SelectionBorder.hide()
	
func _on_click():
	emit_signal("selected", self)

# MARK: Helper functions
func _continue_cpu():
	print("Continue CPU!")
	$CPU.continue_running()
	
func invalidate_timers():
	Clock.clear_timers(self)

func _update_direction_indicator():
	$direction_indicator.set_point_position(1, orientation * 20)

func _update_sprite_direction():
	if orientation.x == -1:
		$Sprite.set_flip_h(true)
	if orientation.x == 1:
		$Sprite.set_flip_h(false)
	
func get_is_blocked():
	var position_on_grid = grid.world_to_grid(self.position)
	var forward = position_on_grid + orientation
	var cell = grid.get_node("Obstacles").get_cell(forward.x, forward.y)
	return cell != -1

# MARK: Function callbacks
func say(text: String):
	$SpeechBubble.show()
	$SpeechBubble/Label.text = text
	$SpeechBubble/Label.set_size($SpeechBubble/Label.get_minimum_size())
	$SpeechBubble.set_size($SpeechBubble.get_minimum_size())
	
	var sleep_time = Time.create_timedelta(0, 0, 0, 20)
	Clock.add_timer(sleep_time, funcref(self, "_continue_cpu"), self)
	Clock.add_timer(sleep_time, funcref(self, "mute"), self)

func mute():
	print("MUTING!")
	$SpeechBubble.hide()

func move_forward():
	if not get_is_blocked():
		var position_on_grid = grid.world_to_grid(self.position)
		var new_pos_grid = position_on_grid + orientation
		var new_pos = grid.grid_to_world(new_pos_grid)

		if not $Tween.is_active():
			$Tween.interpolate_property(self,"position",self.position, new_pos,.5,Tween.TRANS_LINEAR,Tween.EASE_IN)
			$Tween.start()
		else:
			self.position = new_pos
			
		var sleep_time = Time.create_timedelta(0, 0, 0, 20)
		Clock.add_timer(sleep_time, funcref(self, "_continue_cpu"), self)
		
func rotate_left():
	if orientation == Vector2(1, 0):
		orientation = Vector2(0, -1)
	elif orientation == Vector2(0, -1):
		orientation = Vector2(-1, 0)
	elif orientation == Vector2(-1, 0):
		orientation = Vector2(0, 1)
	elif orientation == Vector2(0, 1):
		orientation = Vector2(1, 0)
		
	_update_sprite_direction()
	_update_direction_indicator()
	
	var sleep_time = Time.create_timedelta(0, 0, 0, 20)
	Clock.add_timer(sleep_time, funcref(self, "_continue_cpu"), self)

func rotate_right():
	if orientation == Vector2(1, 0):
		orientation = Vector2(0, 1)
	elif orientation == Vector2(0, 1):
		orientation = Vector2(-1, 0)
	elif orientation == Vector2(-1, 0):
		orientation = Vector2(0, -1)
	elif orientation == Vector2(0, -1):
		orientation = Vector2(1, 0)
		
	_update_sprite_direction()
	_update_direction_indicator()
	
	var sleep_time = Time.create_timedelta(0, 0, 0, 20)
	Clock.add_timer(sleep_time, funcref(self, "_continue_cpu"), self)
	
func get_position() -> Vector2:
	return grid.world_to_grid(self.position)
