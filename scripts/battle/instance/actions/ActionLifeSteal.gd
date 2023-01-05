extends Action

class_name ActionLifeSteal

func _init(actionData, parentChar).(actionData, parentChar):
	pass

func can_execute()->bool:
	return character.successfulDamageThisFrame>0

func execute():
	var lifeStealData:ActionLifeStealData = actionData as ActionLifeStealData
	var lifeSteal:int = 0
	if lifeStealData.percent>0:
		lifeSteal = int(ceil(lifeStealData.percent * float(character.successfulDamageThisFrame)))
	else:
		lifeSteal = lifeStealData.flatAmount

	character.modify_stat_value(StatData.STAT_TYPE.HEALTH, lifeSteal)
