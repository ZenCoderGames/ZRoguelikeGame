
class_name ActionDestroyEffectData extends ActionData

const ID:String = "DESTROY_EFFECT"

var effectId:String

func _init(dataJS):
	super(dataJS)
	effectId = Utils.get_data_from_json(dataJS["params"], "effectId", "INVALID_EFFECT_ID")
