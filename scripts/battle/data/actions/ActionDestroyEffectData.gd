extends ActionData

class_name ActionDestroyEffectData

const ID:String = "DESTROY_EFFECT"

var effectId:String

func _init(dataJS).(dataJS):
    effectId = Utils.get_data_from_json(dataJS["params"], "effectId", "INVALID_EFFECT_ID")
