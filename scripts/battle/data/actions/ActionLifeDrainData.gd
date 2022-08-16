extends ActionData

class_name ActionLifeDrainData

const ID:String = "LIFE_DRAIN"

var percent:float
var flatAmount:int

func _init(dataJS).(dataJS):
	if params.has("percent"):
		percent = params["percent"]
	if params.has("flatAmount"):
		flatAmount = params["flatAmount"]
