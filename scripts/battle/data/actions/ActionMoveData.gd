
class_name ActionMoveData extends ActionData

const ID:String = "MOVEMENT"

enum MOVE_TYPE { INPUT, WANDER, PATHFIND_TO_TARGET }
var moveType:int

func _init(dataJS):
	super(dataJS) 
	var moveTypeStr = params["moveType"]
	if MOVE_TYPE.has(moveTypeStr):
		moveType = MOVE_TYPE.get(moveTypeStr)
	else:
		print("ERROR: Invalid Move Type For ActionMoveData - ", moveTypeStr)
	
