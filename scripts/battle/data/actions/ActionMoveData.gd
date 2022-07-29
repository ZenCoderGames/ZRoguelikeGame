extends "res://scripts/battle/data/actions/ActionData.gd"

class_name ActionMoveData

const ID:String = "MOVEMENT"

var numCells:int

func _init(dataJS).(dataJS):
	numCells = params["numCells"]
