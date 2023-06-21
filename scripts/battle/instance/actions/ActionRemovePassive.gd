
class_name ActionRemovePassive extends Action

func _init(actionData,parentChar):
	super(actionData,parentChar)
	pass

func execute():
	var removePassiveData:ActionRemovePassiveData = actionData as ActionRemovePassiveData

	var passiveData:PassiveData = GameGlobals.dataManager.get_passive_data(removePassiveData.passiveId)
	if passiveData!=null:
		character.remove_passive_from_data(passiveData)
	
