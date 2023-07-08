class_name Stat

var type:int
var maxValue:int
var value:int

signal OnUpdated()
signal OnValueUpdated()
signal OnMaxValueUpdated()

func _init(statData):
	type = statData.type
	value = statData.value
	maxValue = statData.maxValue

func add(val:int):
	modify(value + val)
	return value

func add_max(val:int):
	modify_max(value + val)
	return value

func add_absolute(val:int):
	modify_absolute(value + val)
	return maxValue

func modify(newValue:int):
	_update_value(newValue)
	return value

func modify_max(newMaxValue:int):
	_update_max_value(newMaxValue)
	return maxValue

func modify_absolute(newValue:int):
	_update_max_value(newValue)
	_update_value(maxValue)
	return maxValue

func reset():
	if _is_resetable_stat(type):
		_update_value(maxValue)

func _is_resetable_stat(statType:int):
	return statType == StatData.STAT_TYPE.HEALTH or statType == StatData.STAT_TYPE.DAMAGE

# should this be clamped to 0<maxValue
func _update_value(newValue:int):
	value = newValue
	emit_signal("OnValueUpdated", value)
	emit_signal("OnUpdated")

func _update_max_value(newMaxValue:int):
	maxValue = newMaxValue
	emit_signal("OnMaxValueUpdated", maxValue)
	emit_signal("OnUpdated")
