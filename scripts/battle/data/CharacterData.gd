class_name CharacterData

var id:String
var displayName:String
var path:String
var statDataList:Array
var moveAction:ActionData
var attackAction:ActionData
var disable:bool

func _init(dataJS):
	id = dataJS["id"]
	displayName = dataJS["displayName"]
	path = dataJS["path"]
	
	var statDataJSList = dataJS["stats"]
	for statDataJS in statDataJSList:
		statDataList.append(StatData.new(statDataJS))

	moveAction = ActionDataTypes.create(dataJS["moveAction"])
	attackAction = ActionDataTypes.create(dataJS["attackAction"])
	if dataJS.has("disable"):
		disable =  dataJS["disable"]
