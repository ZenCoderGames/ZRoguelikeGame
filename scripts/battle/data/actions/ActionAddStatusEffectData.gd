extends ActionData

class_name ActionAddStatusEffectData

const ID:String = "ADD_STATUS_EFFECT"

var statusEffectId:String
var applyToSource:bool
var applyToTargets:bool

func _init(dataJS).(dataJS):
    statusEffectId = dataJS["params"]["statusEffectId"]
    applyToSource = Utils.get_data_from_json(dataJS["params"], "applyToSource", false)
    applyToTargets = Utils.get_data_from_json(dataJS["params"], "applyToTargets", false)