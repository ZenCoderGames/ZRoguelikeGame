# Only support Enemy Right now
class_name ActionSpawnCharacterData extends ActionData

const ID:String = "SPAWN_CHARACTER"

var characterId:String
var count:int

func _init(dataJS):
	super(dataJS)
	characterId = Utils.get_data_from_json(dataJS["params"], "characterId", "MISSING_CHARACTER_ID")
	count = Utils.get_data_from_json(dataJS["params"], "count", 1)
