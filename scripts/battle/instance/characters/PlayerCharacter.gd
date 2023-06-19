extends Character

class_name PlayerCharacter

signal OnNearbyEntityFound(entity)
signal OnPlayerReachedExit()
signal OnPlayerReachedEnd()
signal OnXPGained()
signal OnLevelUp()

var levelXpList:Array = [0, 30, 50, 80, 120, 170, 230, 300, 380]
var xp:int = 0
var currentLevel:int = 0
var _levelUpThisTurn:bool = false

@onready var levelUpAnim:Node = $"%LevelUpAnimation"
@onready var levelUpLabel:Node = $"%LevelUpLabel"

func init(charId:int, charData, teamVal):
	super.init(charId, charData, teamVal)

	var moveData:Dictionary = {}
	moveData["type"] = "MOVEMENT"
	moveData["params"] = {}
	moveData["params"]["moveType"] = "INPUT"
	moveAction = ActionTypes.create(ActionDataTypes.create(moveData), self)

	_setup_events()

# This is an init that is for every dungeon except the first init
func init_for_next_dungeon():
	pass
	#_setup_events()
	'''if charData.active!=null:
		special.reset_events()
	if specialPassive!=null:
		specialPassive.reset_events()
	for passive in passiveList:
		passive.reset_events()
	for statusEffect in statusEffectList:
		statusEffect.reset_events()'''

func _setup_events():
	CombatEventManager.connect("OnEnemyMovedAdjacentToPlayer",Callable(self,"on_enemy_moved_adjacent"))
	CombatEventManager.connect("OnLevelUpAbilitySelected",Callable(self,"_on_levelup_ability_selected"))
	HitResolutionManager.connect("OnKill",Callable(self,"_on_kill"))

func pre_update():
	super.pre_update()
	_levelUpThisTurn = false

func update():
	super.update()

	if skipThisTurn:
		skip_turn()
		return

	cell.room.update_path_map()

func post_update():
	super.post_update()

	if isDead:
		return

	if _levelUpThisTurn:
		emit_signal("OnLevelUp")

func can_take_damage()->bool:
	if GameGlobals.battleInstance.setPlayerInvulnerable:
		return false

	return super.can_take_damage()

func move_to_cell(newCell, triggerTurnCompleteEvent:bool=false):
	super.move_to_cell(newCell, triggerTurnCompleteEvent)

	check_for_nearby_entities()

	if newCell.is_exit():
		emit_signal("OnPlayerReachedExit")
	elif newCell.is_end():
		emit_signal("OnPlayerReachedEnd")
	
func on_enemy_moved_adjacent(_enemy):
	check_for_nearby_entities()

func check_for_nearby_entities():
	notify_if_nearby_entity(cell.row-1, cell.col)
	notify_if_nearby_entity(cell.row+1, cell.col)
	notify_if_nearby_entity(cell.row, cell.col-1)
	notify_if_nearby_entity(cell.row, cell.col+1)

func notify_if_nearby_entity(r:int, c:int):
	var cell = currentRoom.get_cell(r, c)
	if cell!=null and cell.has_entity() and cell.is_entity_type(Constants.ENTITY_TYPE.DYNAMIC):
		emit_signal("OnNearbyEntityFound", cell.entityObject)

func _on_kill(attacker, defender, _finalDmg):
	if attacker == self:
		_gain_xp(defender.charData.xp)

func _gain_xp(val:int):
	xp = xp + val
	var prevLevel = currentLevel
	currentLevel = -1
	for levelXp in levelXpList:
		if xp>=levelXp:
			currentLevel = currentLevel + 1
	if prevLevel<currentLevel:
		_level_up()
	emit_signal("OnXPGained")

func _level_up():
	_levelUpThisTurn = true

func get_xp():
	return xp

func get_level():
	return currentLevel

func get_xp_from_current_level():
	return xp - levelXpList[currentLevel]

func get_xp_to_level_xp():
	var nextLevel:int = currentLevel
	if currentLevel<levelXpList.size()-1:
		nextLevel = currentLevel + 1
	return levelXpList[nextLevel] - levelXpList[currentLevel]

func is_at_max_level():
	return currentLevel == levelXpList.size()-1

func _on_levelup_ability_selected(abilityData:AbilityData):
	add_ability(abilityData)

# SKIP_TURN MANAGEMENT
var _lastSkipTurn:int = -1
const SKIP_TURN_COOLDOWN:int = 10

func skip_turn():
	_lastSkipTurn = GameGlobals.dungeon.turnsTaken
	on_turn_completed()

func can_skip_turn():
	return _lastSkipTurn==-1 or (GameGlobals.dungeon.turnsTaken - _lastSkipTurn > SKIP_TURN_COOLDOWN)

func get_skip_turn_cooldown():
	return SKIP_TURN_COOLDOWN - (GameGlobals.dungeon.turnsTaken - _lastSkipTurn) + 1
