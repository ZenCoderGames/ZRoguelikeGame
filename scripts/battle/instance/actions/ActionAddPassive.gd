extends Action

class_name ActionAddPassive

func _init(actionData, parentChar).(actionData, parentChar):
	pass

func can_execute()->bool:
	return true

func execute():
	var addPassiveData:ActionAddPassiveData = actionData as ActionAddPassiveData

	var passiveData:PassiveData = GameGlobals.dataManager.get_passive_data(addPassiveData.passiveId)
	if passiveData!=null:
		character.add_passive(passiveData)
	
