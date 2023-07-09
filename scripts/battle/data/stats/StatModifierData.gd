class_name StatModifierData

var type:int
var value:int
var maxValue:int
var absoluteValue:int

func _init(statModDataJS):
	var statType = statModDataJS["type"]
	if StatData.STAT_TYPE.has(statType):
		type = StatData.STAT_TYPE.get(statType)
	else:
		print("ERROR: Invalid Stat Modifier Type - ", statType)
	
	if statModDataJS.has("value"):
		value = statModDataJS["value"]

	if statModDataJS.has("maxValue"):
		maxValue = statModDataJS["maxValue"]

	if statModDataJS.has("absoluteValue"):
		absoluteValue = statModDataJS["absoluteValue"]
