
class_name ActionRevive extends Action

func _init(actionData,parentChar):
	super(actionData,parentChar)
	pass

func can_execute()->bool:
	return true

func execute():
	var reviveData:ActionReviveData = actionData as ActionReviveData
	character.initiate_revive(reviveData.numTurnsToReviveAfter)
	
