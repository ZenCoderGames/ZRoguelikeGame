class_name DungeonModifierData

var id:String
var description:String
var isPositive:bool

func _init(dataJS):
	id = Utils.get_data_from_json(dataJS, "id", "INVALID_ID")
	description = Utils.get_data_from_json(dataJS, "description", "INVALID_DESCRIPTION")
	isPositive = Utils.get_data_from_json(dataJS, "isPositive", false)
	# TODO STATS/BUFFS
