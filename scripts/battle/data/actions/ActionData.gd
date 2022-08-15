
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

func _init(dataJS):
	type = dataJS["type"]
	params = dataJS["params"]
