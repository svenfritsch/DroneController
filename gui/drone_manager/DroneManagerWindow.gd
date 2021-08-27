extends WindowDialog

var drone_cell_scene = preload("res://gui/drone_manager/DroneListCell.tscn")
onready var list = get_node("ScrollContainer/MarginContainer/VBoxContainer")

var drone_controller

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func clear_cells():
	for drone_cell in list.get_children():
		drone_cell.queue_free()

func add_drone_cell(drone):
	var drone_cell = drone_cell_scene.instance()
	list.add_child(drone_cell)
	drone_cell.set_name(drone.name)
	
func populate():
	if drone_controller:
		for drone in drone_controller.get_children():
			add_drone_cell(drone)
			
func re_populate():
	clear_cells()
	populate()
	
func setup():
	re_populate()
	drone_controller.connect("drones_changed", self, "re_populate")
