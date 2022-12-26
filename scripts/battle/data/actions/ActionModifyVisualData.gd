extends ActionData

class_name ActionModifyVisualData

const ID:String = "MODIFY_VISUAL"

var tintColor:String
var resetToOriginalTint:bool

func _init(dataJS).(dataJS):
    tintColor = Utils.get_data_from_json(dataJS["params"], "tintColor", "")
    resetToOriginalTint = Utils.get_data_from_json(dataJS["params"], "resetToOriginalTint", false)
