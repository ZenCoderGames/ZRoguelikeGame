class_name Stat

var type:int
var baseValue:int
var value:int

var linkedStat:Stat = null
var linkedStatMultiplier:float = 0

func _init(statData):
	type = statData.type
	baseValue = statData.value
	value = statData.value

func add_link_to_stat(stat:Stat, statMultiplier:float):
	linkedStat = stat
	linkedStatMultiplier = statMultiplier
	value = get_base_value()

func get_value():
	return value

func get_base_value():
	if linkedStat!=null:
		return linkedStat.get_value() * linkedStatMultiplier

	return baseValue

func modify_value(newValue:float):
	value = clamp(newValue, 0, get_base_value())
	return value

func modify_base_value(newBaseValue:float):
	baseValue = newBaseValue
	return baseValue
