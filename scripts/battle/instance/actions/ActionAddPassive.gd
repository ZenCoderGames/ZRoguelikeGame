
class_name ActionAddPassive extends Action

func _init(actionData,parentChar):
	super(actionData, parentChar)
	pass

func can_execute()->bool:
	return true

func execute():
	var addPassiveData:ActionAddPassiveData = actionData as ActionAddPassiveData

	var passiveData:PassiveData = GameGlobals.dataManager.get_passive_data(addPassiveData.passiveId)
	if passiveData!=null:
		character.add_passive(passiveData)
	
