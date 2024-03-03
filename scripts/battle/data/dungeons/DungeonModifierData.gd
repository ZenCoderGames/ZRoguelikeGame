class_name DungeonModifierData

var id:String
var description:String
var isPositive:bool
var statModifierDataList:Array
var passiveId:String

func _init(dataJS):
	id = Utils.get_data_from_json(dataJS, "id", "INVALID_ID")
	description = Utils.get_data_from_json(dataJS, "description", "INVALID_DESCRIPTION")
	isPositive = Utils.get_data_from_json(dataJS, "isPositive", false)

	if dataJS.has("statModifiers"):
		var statModifierDataJSList = dataJS["statModifiers"]
		for statModifierDataJS in statModifierDataJSList:
			statModifierDataList.append(StatModifierData.new(statModifierDataJS))
	
	passiveId = Utils.get_data_from_json(dataJS, "passiveId", "")
