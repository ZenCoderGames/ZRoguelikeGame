extends Character

class_name EnemyCharacter

@onready var counterHolder:TextureRect = $"%CounterHolder"
@onready var counterText:Label = $"%CounterText"
@onready var counterReady:TextureRect = $"%CounterReady"

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
		if GameGlobals.battleInstance.debugLevelScaling>0:
			level = GameGlobals.battleInstance.debugLevelScaling
		displayName = str(displayName, " (Lvl: ", str(level+1), ")")
		for stat in stats:
			stat.scale_with_level(level)
		
		on_stats_changed()

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

	_hide_counter()
	for special in specialList:
		if special.isAvailable:
			if !special.try_activate():
				_show_counter_ready_to_attack()
			#if special.try_activate():
			#	on_turn_completed()
			#	return
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

func _show_counter_text(entity, val:String, duration:float=0.75):
	counterHolder.visible = true
	counterReady.visible = false
	counterText.visible = true
	counterText.text = val
	_create_damage_text_tween(entity)

func _show_counter_ready_to_attack():
	counterHolder.visible = true
	counterReady.visible = true
	counterText.visible = false
	
func _hide_counter():
	counterHolder.visible = false

func clean_up_on_death():
	super.clean_up_on_death()
	
	_hide_counter()
