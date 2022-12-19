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
	baseValue = get_base_value()
	value = get_base_value()

func get_value():
	return value

func get_base_value():
	if linkedStat!=null:
		return linkedStat.get_value() * linkedStatMultiplier

	return baseValue

func modify_value(newValue:int):
	value = clamp(newValue, 0, baseValue)
	return value

func modify_base_value(newBaseValue:int):
	baseValue = newBaseValue
	return baseValue
	
func modify_absolute_value(newValue:int):
	baseValue = newValue
	value = newValue
	return newValue

func reset_value():
	value = baseValue

func update_from_modified_linked_stat():
	var prevBaseValue:int = baseValue
	var newBaseValue:int = get_base_value()
	var diff:int = newBaseValue - prevBaseValue
	baseValue = newBaseValue
	value = value + diff
