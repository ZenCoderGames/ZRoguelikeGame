
class_name ActionMove extends Action

func _init(actionData,parentChar):
	super(actionData,parentChar)
	pass

func can_execute()->bool:
	if GameGlobals.battleInstance.pauseAIMovement and character.team == Constants.TEAM.ENEMY:
		return false

	return true

func execute():
	var actionMoveData:ActionMoveData = actionData as ActionMoveData
	# Pathfind
	if actionMoveData.moveType == ActionMoveData.MOVE_TYPE.PATHFIND_TO_TARGET:
		var nextCell = character.currentRoom.find_next_best_path_cell(character)
		if nextCell!=null and nextCell!=character.cell:
			character.move(nextCell.col-character.cell.col, nextCell.row-character.cell.row)
		else:
			character.failed_to_move()
	# Wander
	elif actionMoveData.moveType == ActionMoveData.MOVE_TYPE.WANDER:
		var randomX:int = 0
		var randomY:int = 0
		if randi()%10<5:
			randomX = 1 if randi() % 100 < 50 else -1
		else:
			randomY = 1 if randi() % 100 < 50 else -1
		character.move(randomX, randomY)
