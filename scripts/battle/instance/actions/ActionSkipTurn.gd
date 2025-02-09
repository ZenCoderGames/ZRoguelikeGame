class_name ActionSkipTurn extends Action

func _init(actionData,parentChar):
	super(actionData,parentChar)
	pass

func execute():
	var actionSkipTurnData:ActionSkipTurnData = actionData as ActionSkipTurnData
	var playerChar:PlayerCharacter = (character as PlayerCharacter)
	if playerChar!=null:
		playerChar.skip_turn()
	
