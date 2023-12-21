extends Character

class_name EnemyCharacter

var USE_SIMPLE_LOS:bool
var _hasSeenPlayer:bool
var lastVisitedCellsSincePlayerMoved:Array
var isMiniboss:bool

func init(charId:int, charDataVal, teamVal):
	super.init(charId, charDataVal, teamVal)

	var moveData:Dictionary = {}
	moveData["type"] = "MOVEMENT"
	moveData["params"] = {}
	moveData["params"]["moveType"] = "PATHFIND_TO_TARGET"
	moveAction = ActionTypes.create(ActionDataTypes.create(moveData), self)

	GameGlobals.dungeon.player.connect("OnCharacterMoveToCell",Callable(self,"_on_player_moved"))

	if GameGlobals.battleInstance.useLevelScalingOnEnemies:
		var level:int = GameGlobals.battleInstance.currentDungeonIdx
		displayName = str(displayName, " (Lvl: ", str(level+1), ")")
		for stat in stats:
			stat.add_absolute(level)

func update():
	#if _hasUpdatedThisTurn: For some reason this is bugged out when going really fast with the player
	#	return

	super.update()

	if skipThisTurn:
		skip_turn()
		return

	if USE_SIMPLE_LOS:
		if !_hasSeenPlayer:
			if _is_player_in_los():
				_hasSeenPlayer = true
			else:
				return

	if GameGlobals.dungeon.player.status.is_invisible():
		on_turn_completed()
		return

	for special in specialList:
		if special.isAvailable:
			if special.try_activate():
				on_turn_completed()
				return
		else:
			_show_counter_text(self, str(special.get_remaining_count()))

	if attackAction.can_execute():
		attackAction.execute()
	elif moveAction.can_execute():
		moveAction.execute()
	else:
		on_turn_completed()

func can_take_damage()->bool:
	if GameGlobals.battleInstance.setEnemiesInvulnerable:
		return false

	return super.can_take_damage()

func move_to_cell(newCell, triggerTurnCompleteEvent:bool=false):
	super.move_to_cell(newCell, triggerTurnCompleteEvent)

	if GameGlobals.dungeon.player!=null:
		if(newCell.is_rowcol_adjacent(GameGlobals.dungeon.player.cell)):
			CombatEventManager.emit_signal("OnEnemyMovedAdjacentToPlayer", self)
		
		if !lastVisitedCellsSincePlayerMoved.has(newCell):
			lastVisitedCellsSincePlayerMoved.append(newCell)

func on_ally_has_died():
	lastVisitedCellsSincePlayerMoved.clear()

func _on_player_moved():
	lastVisitedCellsSincePlayerMoved.clear()

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
			if nextCell == GameGlobals.dungeon.player.cell:
				return true
			if !nextCell.is_empty():
				return false
		else:
			break

	return false

func set_as_miniboss():
	isMiniboss = true
	modify_absolute_stat_value(StatData.STAT_TYPE.DAMAGE, get_stat_max_value(StatData.STAT_TYPE.DAMAGE)/2)
	modify_absolute_stat_value(StatData.STAT_TYPE.HEALTH, get_stat_max_value(StatData.STAT_TYPE.HEALTH)/2)
	originalColor = GameGlobals.battleInstance.view.minibossDamageColor
	reset_color()
	displayName = "(Elite) " + displayName
