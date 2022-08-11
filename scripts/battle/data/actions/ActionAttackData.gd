extends ActionData

class_name ActionAttackData

const ID:String = "ATTACK"

var damageMultiplier:float

func _init(dataJS).(dataJS):
	damageMultiplier = dataJS["params"]["damageMultiplier"]
