
class_name ActionFindTargets extends Action

func _init(actionData,parentChar):
	super(actionData,parentChar)
	pass

func can_execute()->bool:
	return true

func execute():
	var findTargetData:ActionFindTargetsData = actionData as ActionFindTargetsData

	character.clear_targets()

	if findTargetData.lastHitTarget:
		if character.lastHitTarget!=null:
			character.add_target(character.lastHitTarget)
		return

	if findTargetData.lastKilledTarget:
		if character.lastKilledTarget!=null:
			character.add_target(character.lastKilledTarget)
		return

	if findTargetData.lastEnemyThatHitMe:
		if character.lastEnemyThatHitMe!=null:
			character.add_target(character.lastEnemyThatHitMe)
		return

	if findTargetData.cellRange>0:
		var adjacentChars:Array = GameGlobals.dungeon.get_adjacent_characters(character, Constants.RELATIVE_TEAM.ENEMY, (actionData as ActionFindTargetsData).cellRange)
		
		for i in findTargetData.maxTargets:
			if i>=adjacentChars.size():
				break
			character.add_target(adjacentChars[i])
