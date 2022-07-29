extends ActionData

class_name ActionMoveData

const ID:String = "MOVEMENT"

var numCells:int

func _init(dataJS).(dataJS):
	numCells = params["numCells"]
