extends ActionData

class_name ActionLifeDrainData

const ID:String = "LIFEDRAIN"

var flatAmount:int

func _init(dataJS).(dataJS):
	flatAmount = Utils.get_data_from_json(params, "flatAmount", 0)
