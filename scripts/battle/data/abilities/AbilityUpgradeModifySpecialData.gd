extends AbilityUpgradeData

class_name AbilityUpgradeModifySpecialData

const ID:String = "MODIFY_SPECIAL"

var specialId:String
var countModifier:int

func _init(dataJS).(dataJS):
    specialId = params["specialId"]
    countModifier = Utils.get_data_from_json(params, "countModifier", 0)