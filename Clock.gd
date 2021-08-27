extends Node

var SPEED = 50

var timer = 0
var timer_limit = 1 / SPEED

signal tick(time_stamp)

var time: Dictionary = Time.create_timestamp(1, 6, 0, 0)

var _timer = []

func _timers_scheduled_to_fire() -> Array:
	var timers_to_fire = []
	for i in self._timer.size():
		var timer = self._timer[i]
		if Time.greater_or_equal(time, timer["fire_at"]):
			timers_to_fire.append(timer)
			
	if timers_to_fire.size() > 0:
		print("========================================")
		print(timers_to_fire)
		
	return timers_to_fire

func _fire_timers():
	var timers_to_fire = _timers_scheduled_to_fire()
	
	if timers_to_fire.size() > 0:
		print("--> ", self._timer.size())
		
	for timer in timers_to_fire:
		print("FIRE!")
		timer.callback.call_func()
		self._timer.erase(timer)
	
	if timers_to_fire.size() > 0:
		print("--> ", self._timer.size())

func add_timer(fire_in: Dictionary, callback: FuncRef, ref):
	print("Adding a timer..")
	self._timer.append({
		"fire_at": Time.add(time, fire_in),
		"callback": callback,
		"reference": ref,
	})
	
func clear_timers(ref):
	var ref_timers = []
	for i in self._timer.size():
		var timer = self._timer[i]
		if timer.reference == ref:
			ref_timers.append(timer)
	
	for ref_timer in ref_timers:
		self._timer.erase(ref_timer)

func _physics_process(delta):
	timer += delta
	
	if timer > timer_limit:
		timer -= timer_limit
		
		var time_stamp_second = Time.create_timedelta(0,0,0,1)
		
		time = Time.add(time, time_stamp_second)
		
		_fire_timers()
					
		emit_signal("tick", time)

