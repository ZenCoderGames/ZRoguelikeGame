class_name LevelData

var id:String
var name:String
var description:String
var dungeonPath:String
var dungeonModifiers:Array
var heroList:Array

func _init(dataJS):
	id = Utils.get_data_from_json(dataJS, "id", "INVALID_ID")
	name = Utils.get_data_from_json(dataJS, "name", "INVALID_NAME")
	description = Utils.get_data_from_json(dataJS, "description", "INVALID_DESCRIPTION")
	dungeonPath = Utils.get_data_from_json(dataJS, "dungeonPath", "INVALID_DUNGEON_PATH")
	if dataJS.has("dungeonModifiers"):
		dungeonModifiers = dataJS["dungeonModifiers"]
	if dataJS.has("heroList"):
		heroList = dataJS["heroList"]
