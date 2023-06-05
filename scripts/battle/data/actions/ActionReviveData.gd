
class_name ActionReviveData extends ActionData

const ID:String = "REVIVE"

var numTurnsToReviveAfter:int

func _init(dataJS):
	super(dataJS)
	
	numTurnsToReviveAfter = Utils.get_data_from_json(dataJS["params"], "numTurnsToReviveAfter", 1)
