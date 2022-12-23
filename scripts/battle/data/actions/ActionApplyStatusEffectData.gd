extends ActionData

class_name ActionApplyStatusEffectData

const ID:String = "APPLY_STATUS_EFFECT"

var statusEffectId:String
var target:String

func _init(dataJS).(dataJS):
    statusEffectId = dataJS["params"]["statusEffectId"]
    target = Utils.get_data_from_json(dataJS["params"], "target", "SELF")