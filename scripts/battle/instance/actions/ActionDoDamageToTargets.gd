extends Action

class_name ActionDoDamageToTargets

func _init(actionData, parentChar).(actionData, parentChar):
	pass

func can_execute()->bool:
	if Dungeon.battleInstance.pauseAIAttack and character.team == Constants.TEAM.ENEMY:
		return false

	return character.has_targets()

func execute():
	var targets = character.get_targets()
	for target in targets:
		HitResolutionManager.do_hit(character, target, actionData.damage)
