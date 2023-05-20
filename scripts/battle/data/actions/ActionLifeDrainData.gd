
class_name ActionLifeDrainData  extends ActionData

const ID:String = "LIFEDRAIN"

var flatAmount:int

func _init(dataJS):
	super(dataJS)
	flatAmount = Utils.get_data_from_json(params, "flatAmount", 0)
