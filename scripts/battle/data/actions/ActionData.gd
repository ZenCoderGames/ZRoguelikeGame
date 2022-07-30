
"""{
	"id": "MOVE",
	"staminaCost": 1,
	"class": "MOVEMENT",
	"params": {
		"numCells": 1
	}
}"""

class_name ActionData

var id:String
var staminaCost:int
var priority:int
var type:String
var params:Dictionary

func _init(dataJS):
	id = dataJS["id"]
	staminaCost = dataJS["staminaCost"]
	priority = dataJS["priority"]
	type = dataJS["type"]
	params = dataJS["params"]
