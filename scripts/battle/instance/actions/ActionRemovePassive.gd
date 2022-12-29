extends Action

class_name ActionRemovePassive

func _init(actionData, parentChar).(actionData, parentChar):
	pass

func can_execute()->bool:
	return true

func execute():
    var removePassiveData:ActionRemovePassiveData = actionData as ActionRemovePassiveData

    var passiveData:PassiveData = GameGlobals.dataManager.get_passive_data(removePassiveData.passiveId)
    if passiveData!=null:
        character.remove_passive_from_data(passiveData)
    