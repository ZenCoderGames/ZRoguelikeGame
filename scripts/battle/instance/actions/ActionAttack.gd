
class_name ActionAttack extends Action

func _init(actionData,parentChar):
	super(actionData, parentChar)
	pass

func can_execute()->bool:
	if !super.can_execute():
		return false

	if GameGlobals.battleInstance.pauseAIAttack and character.team == Constants.TEAM.ENEMY:
		return false

	var adjacentChars:Array = GameGlobals.dungeon.get_adjacent_characters(character, Constants.RELATIVE_TEAM.ENEMY)
	return adjacentChars.size()>0

func execute():
	var adjacentChars:Array = GameGlobals.dungeon.get_adjacent_characters(character, Constants.RELATIVE_TEAM.ENEMY)
	character.attack(adjacentChars[0])
