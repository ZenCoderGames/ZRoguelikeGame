class_name StatData

enum STAT_TYPE { HEALTH, DAMAGE, ARMOR }
var type:int

var value:int

func _init(statDataJS):
    var statType = statDataJS["type"]
    if STAT_TYPE.has(statType):
        type = STAT_TYPE.get(statType)
    else:
        print("ERROR: Invalid Stat Type - ", statType)
    value = statDataJS["value"]