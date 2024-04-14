class_name SkillData

var id:String
var name:String
var description:String
var unlockCost:int
var uiHolderId:String
var parentSkillId:String
var dungeonModifiers:Array
var abilities:Array
var specials:Array
var passives:Array
var items:Array

func _init(dataJS):
	id = dataJS["id"]
	name = dataJS["name"]
	description = dataJS["description"]
	unlockCost = Utils.get_data_from_json(dataJS, "unlockCost", 0)
	uiHolderId = Utils.get_data_from_json(dataJS, "uiHolderId", "")
	parentSkillId = Utils.get_data_from_json(dataJS, "parentSkillId", "")

	if dataJS.has("dungeonModifiers"):
		dungeonModifiers = dataJS["dungeonModifiers"]

	if dataJS.has("abilities"):
		abilities = dataJS["abilities"]

	if dataJS.has("specials"):
		specials = dataJS["specials"]

	if dataJS.has("passives"):
		passives = dataJS["passives"]

	if dataJS.has("items"):
		items = dataJS["items"]
