extends ActionData

class_name ActionLifeDrainData

const ID:String = "LIFE_DRAIN"

var percent:float

func _init(dataJS).(dataJS):
	percent = params["percent"]