extends ActionData

class_name ActionDoDamageToTargetsData

const ID:String = "DO_DAMAGE_TO_TARGETS"

var damage:int

func _init(dataJS).(dataJS):
	damage = Utils.get_data_from_json(dataJS["params"], "damage", 0)
	
