class_name StatData

enum STAT_TYPE { HEALTH, DAMAGE, ARMOR, VITALITY, STRENGTH }
var type:int

var value:int

func init_from_json(statDataJS):
	var statType = statDataJS["type"]
	if STAT_TYPE.has(statType):
		type = STAT_TYPE.get(statType)
	else:
		print("ERROR: Invalid Stat Type - ", statType)
	value = statDataJS["value"]

func init_from_code(statType, statValue):
	type = statType
	value = statValue

func get_stat_name():
	return STAT_TYPE.keys()[type]
