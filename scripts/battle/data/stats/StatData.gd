class_name StatData

enum STAT_TYPE { HEALTH, DAMAGE, ARMOR, ENERGY }
var type:int

var value:int
var maxValue:int

func init_from_json(statDataJS):
	var statType = statDataJS["type"]
	if STAT_TYPE.has(statType):
		type = STAT_TYPE.get(statType)
	else:
		print("ERROR: Invalid Stat Type - ", statType)
	value = Utils.get_data_from_json(statDataJS, "value", 0)
	maxValue = Utils.get_data_from_json(statDataJS, "maxValue", value)

func get_stat_name():
	return STAT_TYPE.keys()[type]
