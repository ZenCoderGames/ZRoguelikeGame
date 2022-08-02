extends ActionData

class_name ActionAttackData

const ID:String = "ATTACK"

var damageMultiplier:float
var cellRange:int

func _init(dataJS).(dataJS):
	damageMultiplier = dataJS["params"]["damageMultiplier"]
	cellRange = dataJS["params"]["range"]
