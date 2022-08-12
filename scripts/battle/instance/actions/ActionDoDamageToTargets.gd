extends Action

class_name ActionDoDamageToTargets

func _init(actionData, parentChar).(actionData, parentChar):
	pass

func can_execute()->bool:
	if Dungeon.battleInstance.pauseAIAttack and character.team == Constants.TEAM.ENEMY:
		return false

	return character.has_targets()

func execute():
	var randomTarget = character.get_random_target()
	randomTarget.take_damage(character, actionData.damage)
