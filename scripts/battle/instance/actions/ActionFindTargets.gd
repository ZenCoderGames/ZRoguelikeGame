extends Action

class_name ActionFindTargets

func _init(actionData, parentChar).(actionData, parentChar):
	pass

func can_execute()->bool:
	return true

func execute():
	if actionData.lastHitTarget:
		if character.lastHitTarget!=null:
			character.add_target(character.lastHitTarget)
		return

	if actionData.lastKilledTarget:
		if character.lastKilledTarget!=null:
			character.add_target(character.lastKilledTarget)
		return

	if actionData.cellRange>0:
		var adjacentChars:Array = GameGlobals.dungeon.get_adjacent_characters(character, Constants.RELATIVE_TEAM.ENEMY, (actionData as ActionFindTargetsData).cellRange)
		
		for i in actionData.maxTargets:
			if i>=adjacentChars.size():
				break
			character.add_target(adjacentChars[i])
