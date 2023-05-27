extends ActionData

class_name ActionLifeStealData

const ID:String = "LIFESTEAL"

var percent:float
var flatAmount:int

func _init(dataJS):
	super(dataJS)
	percent = Utils.get_data_from_json(params, "percent", 0)
	flatAmount = Utils.get_data_from_json(params, "flatAmount", 0)
