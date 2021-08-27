extends MenuButton

onready var drone_controller = get_node("/root/Game/World/DroneController")
onready var editor = get_node("../../../../ScriptEdit")

var popup

func _ready():
	popup = get_popup()
	generate_items()
	popup.connect("id_pressed", self, "_on_item_pressed")
	if drone_controller:
		drone_controller.connect("drones_changed", self, "_on_drones_changed")
	
func clear_items():
	popup.clear()
	
func generate_items():
	if drone_controller:
		print(drone_controller.get_children())
		for drone in drone_controller.get_children():
			popup.add_item(drone.name)
			
		popup.add_separator()
		popup.add_item("All")

func _on_item_pressed(ID):
	print(popup.get_item_text(ID), " pressed")
	
	var program = []
	for i in editor.get_line_count():
		program.append(editor.get_line(i))
		
	drone_controller.drone_run(
		popup.get_item_text(ID),
		program
	)
	
func _on_drones_changed():
	clear_items()
	generate_items()
