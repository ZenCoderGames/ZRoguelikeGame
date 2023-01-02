extends ActionData

class_name ActionModifySpecialData

const ID:String = "MODIFY_SPECIAL"

var specialId:String
var countModifier:int
var refill:bool

func _init(dataJS).(dataJS):
    specialId = Utils.get_data_from_json(params, "specialId", "INVALID SPECIAL ID")
    countModifier = Utils.get_data_from_json(params, "countModifier", 0)
    refill = Utils.get_data_from_json(params, "refill", false)
