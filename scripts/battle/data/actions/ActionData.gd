
"""{
	"id": "MOVE",
	"staminaCost": 1,
	"class": "MOVEMENT",
	"params": {
		"numCells": 1
	}
}"""

class_name ActionData

var id
var staminaCost
var type
var params

func _init(dataJS):
	id = dataJS["id"]
	staminaCost = dataJS["staminaCost"]
	type = dataJS["type"]
	params = dataJS["params"]
