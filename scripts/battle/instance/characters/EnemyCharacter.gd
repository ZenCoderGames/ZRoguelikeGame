extends Character

class_name EnemyCharacter

var USE_SIMPLE_LOS:bool
var _hasSeenPlayer:bool

func init(charDataVal, teamVal):
	.init(charDataVal, teamVal)

func update():
	.update()

	if USE_SIMPLE_LOS:
		if !_hasSeenPlayer:
			if _is_player_in_los():
				_hasSeenPlayer = true
			else:
				return

	if attackAction.can_execute():
		attackAction.execute()
	elif moveAction.can_execute():
		moveAction.execute()
	else:
		on_turn_completed()

func move_to_cell(newCell, triggerTurnCompleteEvent:bool=false):
	.move_to_cell(newCell, triggerTurnCompleteEvent)

	if Dungeon.player!=null:
		if(newCell.is_rowcol_adjacent(Dungeon.player.cell)):
			Dungeon.emit_signal("OnEnemyMovedAdjacentToPlayer", self)

func _is_player_in_los():
	if _los_check_in_dirn(0, 1) or\
		_los_check_in_dirn(0, -1) or\
		_los_check_in_dirn(1, 0) or\
		_los_check_in_dirn(-1, 0) or\
		_los_check_in_dirn(1, 1) or\
		_los_check_in_dirn(1, -1) or\
		_los_check_in_dirn(-1, 1) or\
		_los_check_in_dirn(-1, -1):
		return true

	return false

func _los_check_in_dirn(rDir:int, cDir:int):
	var newR:int = cell.row
	var newC:int = cell.col
	while(true):
		newR = newR + rDir * 1
		newC = newC + cDir * 1
		var nextCell:DungeonCell = currentRoom.get_cell(newR, newC)
		if nextCell!=null:
			if nextCell == Dungeon.player.cell:
				return true
			if !nextCell.is_empty():
				return false
		else:
			break

	return false
