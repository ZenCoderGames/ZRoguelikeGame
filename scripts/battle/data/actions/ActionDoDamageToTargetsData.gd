
class_name ActionDoDamageToTargetsData extends ActionData

const ID:String = "DO_DAMAGE_TO_TARGETS"

var damage:int
var useCharacterDamage:bool

func _init(dataJS):
	super(dataJS)
	damage = Utils.get_data_from_json(dataJS["params"], "damage", 0)
	useCharacterDamage = Utils.get_data_from_json(dataJS["params"], "useCharacterDamage", false)
