class_name Action

var actionData:ActionData
var character

func _init(data:ActionData,parentChar):
	actionData = data
	character = parentChar

func can_execute()->bool:
	if actionData.team == Constants.TEAM.NONE:
		return true
	else:
		return character.team == actionData.team

func execute():
	pass
