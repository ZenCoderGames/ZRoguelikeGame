
class_name ActionPushData extends ActionData

const ID:String = "PUSH"

var amount:int
var awayFromSource:bool

func _init(dataJS):
	super(dataJS)
	amount = Utils.get_data_from_json(dataJS["params"], "amount", 0)
	awayFromSource = Utils.get_data_from_json(dataJS["params"], "awayFromSource", false)
