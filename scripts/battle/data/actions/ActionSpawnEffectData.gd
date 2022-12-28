extends ActionData

class_name ActionSpawnEffectData

const ID:String = "SPAWN_EFFECT"

var effectId:String
var effectPath:String
var parent:bool
var lifetime:float

func _init(dataJS).(dataJS):
    effectId = Utils.get_data_from_json(dataJS["params"], "effectId", "INVALID_EFFECT_ID")
    effectPath = Utils.get_data_from_json(dataJS["params"], "effectPath", "INVALID_EFFECT_PATH")
    parent = Utils.get_data_from_json(dataJS["params"], "parent", false)
    lifetime = Utils.get_data_from_json(dataJS["params"], "lifetime", -1)
