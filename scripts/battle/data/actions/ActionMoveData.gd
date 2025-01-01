
class_name ActionMoveData extends ActionData

const ID:String = "MOVEMENT"

enum MOVE_TYPE { INPUT, WANDER, PATHFIND_TO_TARGET, DIRECTIONAL }
var moveType:int
var value:int

func _init(dataJS):
	super(dataJS) 
	var moveTypeStr = params["moveType"]
	if MOVE_TYPE.has(moveTypeStr):
		moveType = MOVE_TYPE.get(moveTypeStr)
	else:
		print("ERROR: Invalid Move Type For ActionMoveData - ", moveTypeStr)
	value = Utils.get_data_from_json(dataJS["params"], "value", 0)
	
