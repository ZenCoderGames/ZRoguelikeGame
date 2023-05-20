
class_name ActionAddPassiveData extends ActionData

const ID:String = "ADD_PASSIVE"

var passiveId:String

func _init(dataJS):
	super(dataJS)
	passiveId = Utils.get_data_from_json(dataJS["params"], "passiveId", "INVALID_PASSIVE_ID")
