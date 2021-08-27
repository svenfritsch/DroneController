extends Node

func _validate_integrity(time: Dictionary):
	while time.seconds > 60:
		time.seconds -= 60
		time.minutes += 1
		
	while time.minutes > 60:
		time.minutes -= 60
		time.hours += 1
		
	while time.hours > 24:
		time.hours -= 24
		time.days += 1
		
	return time

func create_timestamp(
	days: int = 0,
	hours: int = 0,
	minutes: int = 0,
	seconds: int = 0
):
	return _validate_integrity({
		"days": days,
		"hours": hours,
		"minutes": minutes,
		"seconds": seconds,
	})
	
func create_timedelta(
	days: int = 0,
	hours: int = 0,
	minutes: int = 0,
	seconds: int = 0
):
	return create_timestamp(days, hours, minutes, seconds)

func add(time: Dictionary, delta: Dictionary) -> Dictionary:
	return create_timestamp(
		time.days + delta.days,
		time.hours + delta.hours,
		time.minutes + delta.minutes,
		time.seconds + delta.seconds
	)
	
func equal(a: Dictionary, b: Dictionary) -> bool:
	return (a.days == b.days) and (a.hours == b.hours) and (a.minutes == b.minutes) and (a.seconds == b.seconds)
	
func greater_or_equal(a: Dictionary, b: Dictionary) -> bool:
	if a.days == b.days:
		if a.hours == b.hours:
			if a.minutes == b.minutes:
				if a.seconds == b.seconds:
					return true
				else:
					return a.seconds > b.seconds
			else:
				return a.minutes > b.minutes
		else:
			return a.hours > b.hours
	else:
		return a.days > b.days
