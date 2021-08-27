extends Node

var drone_scene = preload("res://entities/Drone.tscn")
onready var world = get_parent()

var selected_drone

signal drone_selection_changed(drone)
signal spawned_drone(drone)
signal drones_changed()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _generate_random_name() -> String:
	var rng = RandomNumberGenerator.new()
	var drone_types = [
		"bb", "gg", "bm", "wc", "dd"
	]
	var drone_type = drone_types[randi() % drone_types.size()]
	return "%s-%s" % [drone_type, String(rng.randi_range(10, 99))]
	
func spawn_drone(x: int, y: int):
	var drone = drone_scene.instance()
	drone.name = _generate_random_name()
	drone.connect("selected", self, "set_selected")
	add_child(drone)
	var spawn_pos = world.map_to_world(Vector2(x, y))
	drone.position = spawn_pos
	emit_signal("spawned_drone", drone)
	emit_signal("drones_changed")
	
func set_selected(drone):
	selected_drone = drone
	drone.get_node("Camera").current = true
	emit_signal("drone_selection_changed", selected_drone)
	
func get_drone(name: String):
	return get_node(name)
	
func drone_run(name: String, program: Array):
	var drone = get_drone(name)
	drone.get_node("CPU").start(program)
	
func _on_Toolbar_spawn_drone_requested():
	spawn_drone(0, 0)
