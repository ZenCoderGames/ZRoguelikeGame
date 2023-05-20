
class_name ActionModifyVisualData extends ActionData

const ID:String = "MODIFY_VISUAL"

var tintColor:String
var resetToOriginalTint:bool

func _init(dataJS):
	super(dataJS)
	tintColor = Utils.get_data_from_json(dataJS["params"], "tintColor", "")
	resetToOriginalTint = Utils.get_data_from_json(dataJS["params"], "resetToOriginalTint", false)
