class_name DungeonModifierData

var id:String
var description:String

func _init(dataJS):
	id = Utils.get_data_from_json(dataJS, "id", "INVALID_ID")
	description = Utils.get_data_from_json(dataJS, "description", "INVALID_DESCRIPTION")
	# TODO STATS/BUFFS
