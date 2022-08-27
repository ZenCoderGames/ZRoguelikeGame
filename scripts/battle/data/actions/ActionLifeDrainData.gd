extends ActionData

class_name ActionLifeDrainData

const ID:String = "LIFE_DRAIN"

var percent:float
var flatAmount:int

func _init(dataJS).(dataJS):
	percent = Utils.get_data_from_json(params, "percent", 0)
	flatAmount = Utils.get_data_from_json(params, "flatAmount", 0)
