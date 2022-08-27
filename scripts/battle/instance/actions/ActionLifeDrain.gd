extends Action

class_name ActionLifeDrain

func _init(actionData, parentChar).(actionData, parentChar):
	pass

func can_execute()->bool:
	return character.successfulDamageThisFrame>0

func execute():
	var lifeDrainData:ActionLifeDrainData = actionData as ActionLifeDrainData
	var lifeLeeched:int = 0
	if lifeDrainData.percent>0:
		lifeLeeched = lifeDrainData.percent * character.successfulDamageThisFrame
	else:
		lifeLeeched = lifeDrainData.flatAmount

	character.modify_stat_value(StatData.STAT_TYPE.HEALTH, lifeLeeched)

	var targets = character.get_targets()
	for target in targets:
		if !target.isDead:
			HitResolutionManager.do_hit(character, target, lifeLeeched, false)
