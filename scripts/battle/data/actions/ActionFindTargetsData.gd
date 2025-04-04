
class_name ActionFindTargetsData extends ActionData

const ID:String = "FIND_TARGETS"

var maxTargets:int
var cellRange:int
var lastHitTarget:bool
var lastKilledTarget:bool
var lastEnemyThatHitMe:bool
var useSelectedCells:bool

func _init(dataJS):
	super(dataJS)
	cellRange = Utils.get_data_from_json(dataJS["params"], "range", 0)
	maxTargets = Utils.get_data_from_json(dataJS["params"], "maxTargets", 1)
	lastHitTarget = Utils.get_data_from_json(dataJS["params"], "lastHitTarget", false)
	lastKilledTarget = Utils.get_data_from_json(dataJS["params"], "lastKilledTarget", false)
	lastEnemyThatHitMe = Utils.get_data_from_json(dataJS["params"], "lastEnemyThatHitMe", false)
	useSelectedCells = Utils.get_data_from_json(dataJS["params"], "useSelectedCells", false)
