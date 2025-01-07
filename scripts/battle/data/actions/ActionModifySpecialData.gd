
class_name ActionModifySpecialData extends ActionData

const ID:String = "MODIFY_SPECIAL"

var specialId:String
var useLastSpecialAdded:bool
var countModifier:int
var refill:bool

func _init(dataJS):
	super(dataJS)
	specialId = Utils.get_data_from_json(params, "specialId", "")
	useLastSpecialAdded = Utils.get_data_from_json(params, "useLastSpecialAdded", false)
	countModifier = Utils.get_data_from_json(params, "countModifier", 0)
	refill = Utils.get_data_from_json(params, "refill", false)
