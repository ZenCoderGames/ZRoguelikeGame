# Data resource

var id
var displayName
var path
var health
var damage

func _init(dataJS):
	id = dataJS["id"]
	displayName = dataJS["displayName"]
	path = dataJS["path"]
	health = dataJS["health"]
	damage = dataJS["damage"]
