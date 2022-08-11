extends ActionData

class_name ActionFindTargetsData

const ID:String = "FIND_TARGETS"

var maxTargets:int
var cellRange:int

func _init(dataJS).(dataJS):
	cellRange = dataJS["params"]["range"]
	maxTargets = dataJS["params"]["maxTargets"]
	
