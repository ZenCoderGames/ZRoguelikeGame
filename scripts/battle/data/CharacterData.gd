class_name CharacterData

var id:String
var displayName:String
var path:String
var cost:int
var statDataList:Array
var moveAction:ActionData
var attackAction:ActionData
var disable:bool

func _init(dataJS):
	id = dataJS["id"]
	displayName = dataJS["displayName"]
	path = dataJS["path"]
	cost =  Utils.get_data_from_json(dataJS, "cost", 0)
	
	var statDataJSList = dataJS["stats"]
	for statDataJS in statDataJSList:
		statDataList.append(StatData.new(statDataJS))

	moveAction = ActionDataTypes.create(dataJS["moveAction"])
	attackAction = ActionDataTypes.create(dataJS["attackAction"])
	disable =  Utils.get_data_from_json(dataJS, "disable", false)

