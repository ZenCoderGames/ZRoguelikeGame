class_name Stat

var type:int
var maxValue:int
var value:int

func _init(statData):
	type = statData.type
	maxValue = statData.value
	value = statData.value

func modify(newValue:int):
	value = newValue
	if value>maxValue:
		value = maxValue
	if value<0:
		value = 0
	return value

func modify_max(newMaxValue:int):
	maxValue = newMaxValue
	return maxValue
	
func modify_absolute(newValue:int):
	maxValue = newValue
	value = maxValue
	return maxValue

func reset():
	value = maxValue