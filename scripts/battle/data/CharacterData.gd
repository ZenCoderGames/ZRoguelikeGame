class_name CharacterData

var id:String
var displayName:String
var path:String
var statDataList:Array
var actionDataList:Array
var disable:bool

func _init(dataJS, actionDataMap):
	id = dataJS["id"]
	displayName = dataJS["displayName"]
	path = dataJS["path"]
	
	var statDataJSList = dataJS["stats"]
	for statDataJS in statDataJSList:
		statDataList.append(StatData.new(statDataJS))

	var actionDataJSList = dataJS["actions"]
	for actionDataIdJS in actionDataJSList:
		actionDataList.append(actionDataMap[actionDataIdJS])

	if dataJS.has("disable"):
		disable =  dataJS["disable"]
