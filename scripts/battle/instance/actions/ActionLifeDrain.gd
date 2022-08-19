extends Action

class_name ActionLifeDrain

func _init(actionData, parentChar).(actionData, parentChar):
	pass

func can_execute()->bool:
	return character.successfulDamageThisFrame>0

func execute():
	var lifeDrainData:ActionLifeDrainData = actionData as ActionLifeDrainData
	character.modify_stat_value(StatData.STAT_TYPE.HEALTH, lifeDrainData.percent * character.successfulDamageThisFrame)
	character.modify_stat_value(StatData.STAT_TYPE.HEALTH, lifeDrainData.flatAmount)
