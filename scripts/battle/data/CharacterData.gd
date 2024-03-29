class_name CharacterData

var id:String
var displayName:String
var description:String
var portraitPath:String
var spritePath:String
var path:String
var difficulty:int
var cost:int
var xp:int
var statDataList:Array
var moveAction:ActionData
var attackAction:ActionData
var disable:bool
var specialId:String
var passiveId:String
var isGeneric:bool
var isInCharacterSelect:bool
var unlockCost:int

func _init(dataJS):
	id = dataJS["id"]
	displayName = dataJS["displayName"]
	description = Utils.get_data_from_json(dataJS, "description", "")
	portraitPath = Utils.get_data_from_json(dataJS, "portraitPath", "")
	spritePath = Utils.get_data_from_json(dataJS, "spritePath", "")
	path = dataJS["path"]
	difficulty = Utils.get_data_from_json(dataJS, "difficulty", 1)
	cost =  Utils.get_data_from_json(dataJS, "cost", 0)
	xp =  Utils.get_data_from_json(dataJS, "xp", 0)
	unlockCost =  Utils.get_data_from_json(dataJS, "unlockCost", 0)
	isGeneric = Utils.get_data_from_json(dataJS, "isGeneric", false)
	isInCharacterSelect = Utils.get_data_from_json(dataJS, "isInCharacterSelect", false)
	
	var statDataJSList = dataJS["stats"]
	for statDataJS in statDataJSList:
		var statData:StatData = StatData.new()
		statData.init_from_json(statDataJS)
		statDataList.append(statData)

	_generate_inherent_stat(StatData.STAT_TYPE.EVASION, 0, 100)
	_generate_inherent_stat(StatData.STAT_TYPE.CRITICAL_CHANCE, 0, 100)
	_generate_inherent_stat(StatData.STAT_TYPE.CRITICAL_DAMAGE, 50, 200)

	disable =  Utils.get_data_from_json(dataJS, "disable", false)

	if dataJS.has("specialId"):
		specialId = Utils.get_data_from_json(dataJS, "specialId", "")

	if dataJS.has("passiveId"):
		passiveId = Utils.get_data_from_json(dataJS, "passiveId", "")

func get_display_name():
	return displayName

func get_description():
	return description

func _generate_inherent_stat(statType:int, value:int, maxValue:int):
	var statData:StatData = StatData.new()
	statData.init_from_data(statType, value, maxValue)
	statDataList.append(statData)
