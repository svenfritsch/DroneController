extends Label

onready var drone_controller = get_node("/root/Game/World/DroneController")

func _ready():
	drone_controller.connect(
		"drone_selection_changed", 
		self, 
		"_on_drone_selection_changed"
	)

func _on_drone_selection_changed(drone):
	text = drone.name
