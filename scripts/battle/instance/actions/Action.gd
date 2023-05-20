class_name Action

var actionData:ActionData
var character

func _init(data:ActionData,parentChar):
	actionData = data
	character = parentChar

func can_execute()->bool:
	return true

func execute():
	pass
