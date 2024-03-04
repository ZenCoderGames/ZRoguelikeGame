extends Node

var _timeInSeconds:float

func _ready():
	_timeInSeconds = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_timeInSeconds = _timeInSeconds + delta

func get_current_time():
	return _timeInSeconds

func get_time_since(prevTime:float):
	return _timeInSeconds - prevTime
