
"""{
	"id": "MOVE",
	"class": "MOVEMENT",
	"params": {
		"numCells": 1
	}
}"""

class_name ActionData

var type:String
var params:Dictionary
var team:int

func _init(dataJS):
	type = dataJS["type"]
	params = dataJS["params"]
	if dataJS.has("team"):
		team = Constants.TEAM.get(dataJS["team"])
	else:
		team = Constants.TEAM.NONE
