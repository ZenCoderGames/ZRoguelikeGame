class_name ComplexStatData

var statType:int
var linkedStatType:int
var linkedStatMultiplier:float

func _init(complexStatDataJS):
	var type = complexStatDataJS["statType"]
	if StatData.STAT_TYPE.has(type):
		statType = StatData.STAT_TYPE.get(type)
	else:
		print("ERROR: Invalid Stat Type - ", type)

	type = complexStatDataJS["linkedStatType"]
	if StatData.STAT_TYPE.has(type):
		linkedStatType = StatData.STAT_TYPE.get(type)
	else:
		print("ERROR: Invalid Linked Stat Type - ", type)
	
	linkedStatMultiplier = complexStatDataJS["linkedStatMultiplier"]
