extends ActionData

class_name ActionFindTargetsData

const ID:String = "FIND_TARGETS"

var maxTargets:int
var cellRange:int
var lastHitTarget:bool
var lastKilledTarget:bool

func _init(dataJS).(dataJS):
	cellRange = Utils.get_data_from_json(dataJS["params"], "range", 0)
	maxTargets = Utils.get_data_from_json(dataJS["params"], "maxTargets", 1)
	lastHitTarget = Utils.get_data_from_json(dataJS["params"], "lastHitTarget", false)
	lastKilledTarget = Utils.get_data_from_json(dataJS["params"], "lastKilledTarget", false)
	
