extends ActionData

class_name ActionPushData

const ID:String = "PUSH"

var amount:int
var awayFromSource:bool

func _init(dataJS).(dataJS):
    amount = Utils.get_data_from_json(dataJS["params"], "amount", 0)
    awayFromSource = Utils.get_data_from_json(dataJS["params"], "awayFromSource", false)
