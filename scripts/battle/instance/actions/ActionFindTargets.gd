extends Action

class_name ActionFindTargets

func _init(actionData, parentChar).(actionData, parentChar):
	pass

func can_execute()->bool:
	return true

func execute():
	var adjacentChars:Array = Dungeon.get_adjacent_characters(character, Constants.RELATIVE_TEAM.ENEMY, (actionData as ActionFindTargetsData).cellRange)
	
	for i in actionData.maxTargets:
		if i>=adjacentChars.size():
			break
		character.add_target(adjacentChars[i])
