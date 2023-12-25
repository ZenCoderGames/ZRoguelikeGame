extends ActionData

class_name ActionTeleportToTargetData

const ID:String = "TELEPORT_TO_TARGET"

var displacement:int

func _init(dataJS):
	super(dataJS)
	displacement = Utils.get_data_from_json(params, "displacement", 1)
