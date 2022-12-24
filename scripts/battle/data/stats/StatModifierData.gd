class_name StatModifierData

var type:int
var value:int
var baseValue:int

func _init(statModDataJS):
	var statType = statModDataJS["type"]
	if StatData.STAT_TYPE.has(statType):
		type = StatData.STAT_TYPE.get(statType)
	else:
		print("ERROR: Invalid Stat Modifier Type - ", statType)
	
	if statModDataJS.has("value"):
		value = statModDataJS["value"]

	if statModDataJS.has("baseValue"):
		baseValue = statModDataJS["baseValue"]
