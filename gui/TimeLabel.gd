extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Clock.connect("tick", self, "update_time")
	
	
func update_time(time):
	var minute_string = String(time.minutes) if time.minutes > 9 else "0%s" % String(time.minutes)
	var hour_string = String(time.hours) if time.hours > 9 else "0%s" % String(time.hours)
	text = "Day %s, %s:%s" % [String(time.days), hour_string, minute_string]


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
