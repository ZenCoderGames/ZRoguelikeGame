extends ActionData

class_name ActionModifyAttackData

const ID:String = "MODIFY_ATTACK"

var damageMultiplier:float
var applyToTargets:bool
var removeModifier:bool

func _init(dataJS).(dataJS):
    damageMultiplier = Utils.get_data_from_json(params, "damageMultiplier", 1.0)
    applyToTargets = Utils.get_data_from_json(params, "applyToTargets", false)
    removeModifier = Utils.get_data_from_json(params, "removeModifier", false)
