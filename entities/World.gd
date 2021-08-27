extends TileMap


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func world_to_grid(position: Vector2) -> Vector2:
	return world_to_map(position / scale)
	
func grid_to_world(position: Vector2) -> Vector2:
	return map_to_world(position) * scale
