extends ActionData

class_name ActionAttackData

const ID:String = "ATTACK"

var damageMultiplier:float

func _init(dataJS).(dataJS):
	damageMultiplier = Utils.get_data_from_json(dataJS["params"], "damageMultiplier", 1)
