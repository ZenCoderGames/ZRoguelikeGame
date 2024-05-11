class_name SkillData

var id:String
var name:String
var description:String
var unlockCost:int
var children:Array
var dungeonModifiers:Array
var abilities:Array
var specials:Array
var passives:Array
var items:Array
var isStartNode:bool
var parentSkillId:String  # Assigned on data read

func _init(dataJS):
	id = dataJS["id"]
	name = dataJS["name"]
	description = dataJS["description"]
	unlockCost = Utils.get_data_from_json(dataJS, "unlockCost", 0)

	if dataJS.has("children"):
		children = dataJS["children"]

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

	isStartNode = Utils.get_data_from_json(dataJS, "isStartNode", false)
