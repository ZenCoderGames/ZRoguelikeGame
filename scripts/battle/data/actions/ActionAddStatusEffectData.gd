
class_name ActionAddStatusEffectData extends ActionData

const ID:String = "ADD_STATUS_EFFECT"

var statusEffectId:String
var applyToSource:bool
var applyToTargets:bool

func _init(dataJS):
	super(dataJS)
	statusEffectId = dataJS["params"]["statusEffectId"]
	applyToSource = Utils.get_data_from_json(dataJS["params"], "applyToSource", false)
	applyToTargets = Utils.get_data_from_json(dataJS["params"], "applyToTargets", false)
