
class_name ActionAttackData extends ActionData

const ID:String = "ATTACK"

var damageMultiplier:float

func _init(dataJS):
	super(dataJS)
	damageMultiplier = Utils.get_data_from_json(dataJS["params"], "damageMultiplier", 1)
