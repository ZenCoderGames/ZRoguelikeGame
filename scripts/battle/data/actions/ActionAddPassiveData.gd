extends ActionData

class_name ActionAddPassiveData

const ID:String = "ADD_PASSIVE"

var passiveId:String

func _init(dataJS).(dataJS):
    passiveId = Utils.get_data_from_json(dataJS["params"], "passiveId", "INVALID_PASSIVE_ID")