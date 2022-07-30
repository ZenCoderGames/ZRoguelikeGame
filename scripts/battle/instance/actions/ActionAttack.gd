extends Action

class_name ActionAttack

func _init(actionData, parentChar).(actionData, parentChar):
	pass

func can_execute()->bool:
    if Dungeon.battleInstance.pauseAIAttack and character.team == Constants.TEAM.ENEMY:
        return false

    var adjacentChars:Array = Dungeon.get_adjacent_characters(character, Constants.RELATIVE_TEAM.ENEMY)
    return adjacentChars.size()>0

func execute():
    var adjacentChars:Array = Dungeon.get_adjacent_characters(character, Constants.RELATIVE_TEAM.ENEMY)
    character.attack(adjacentChars[0])