extends Character

class_name PlayerCharacter

signal OnNearbyEntityFound(entity)
signal OnPlayerReachedExit()
signal OnPlayerReachedEnd()
signal OnXPGained()
signal OnSoulsModified()
signal OnLevelUp()
signal OnEnemyKilled(enemy)

var levelXpList:Array = [0, 30, 50, 80, 120, 170, 230, 300, 380]
var xp:int = 0
var currentLevel:int = 0
var _levelUpThisTurn:bool = false
var _souls:int = 0
var _currentVendorCostMultiplier:float = 1

func init(charIdVal:int, charDataVal, teamVal):
	super.init(charIdVal, charDataVal, teamVal)

	var moveData:Dictionary = {}
	moveData["type"] = "MOVEMENT"
	moveData["params"] = {}
	moveData["params"]["moveType"] = "INPUT"
	moveAction = ActionTypes.create(ActionDataTypes.create(moveData), self)

	_setup_events()

# This is an init that is for every dungeon except the first init
func init_for_next_dungeon():
	pass

func _setup_events():
	CombatEventManager.connect("OnCombatInitialized", Callable(self,"check_for_nearby_entities"))
	CombatEventManager.connect("OnEnemyMovedAdjacentToPlayer",Callable(self,"on_enemy_moved_adjacent"))
	CombatEventManager.connect("OnLevelUpAbilitySelected",Callable(self,"_on_levelup_ability_selected"))
	CombatEventManager.connect("OnVendorItemSelected",Callable(self,"_on_vendor_item_selected"))
	CombatEventManager.connect("OnPlayerSpecialAbilityPressed",Callable(self,"_on_special_pressed"))
	HitResolutionManager.connect("OnPostHit",Callable(self,"_on_post_hit"))
	HitResolutionManager.connect("OnKill",Callable(self,"_on_kill"))

	await get_tree().create_timer(0.05).timeout
	_intro_sequence()

# INTRO SEQUENCE
func _intro_sequence():
	Utils.create_return_tween_vector2(self, "scale", self.scale, Vector2(1.25, 1.25), 0.15, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR, 1.5)
	self.self_modulate = Color.AQUAMARINE
	await get_tree().create_timer(0.2).timeout
	reset_color()

func reset_color():
	self.self_modulate = originalColor

func pre_update():
	super.pre_update()
	_levelUpThisTurn = false

func update():
	if _hasUpdatedThisTurn:
		return
		
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
		if newCell.room.is_cleared():
			emit_signal("OnPlayerReachedExit")
		else:
			CombatEventManager.on_show_info("Exit", "Kill Miniboss to exit")
	elif newCell.is_end():
		if newCell.room.is_cleared():
			end_dungeon()
		else:
			CombatEventManager.on_show_info("Exit", "Kill Boss to exit")
	
func end_dungeon():
	emit_signal("OnPlayerReachedEnd")

func on_enemy_moved_adjacent(_enemy):
	check_for_nearby_entities()

func check_for_nearby_entities():
	notify_if_nearby_entity(cell.row-1, cell.col)
	notify_if_nearby_entity(cell.row+1, cell.col)
	notify_if_nearby_entity(cell.row, cell.col-1)
	notify_if_nearby_entity(cell.row, cell.col+1)

func notify_if_nearby_entity(r:int, c:int):
	var currentCell = currentRoom.get_cell(r, c)
	if currentCell!=null and currentCell.has_entity() and currentCell.is_entity_type(Constants.ENTITY_TYPE.DYNAMIC):
		emit_signal("OnNearbyEntityFound", currentCell.entityObject)

func _on_kill(attacker, defender, _finalDmg):
	if attacker == self:
		#_gain_xp(defender.charData.xp)
		gain_souls(defender.charData.xp)
		emit_signal("OnEnemyKilled", defender)


func _on_post_hit(attacker, _defender, _finalDmg):
	if attacker == self:
		get_stat(StatData.STAT_TYPE.ENERGY).add(1)
		on_stats_changed()

# SOULS
func gain_souls(val:int):
	_souls = _souls + val
	emit_signal("OnSoulsModified")

func get_souls():
	return _souls

func consume_souls(val:int):
	_souls = _souls - val
	emit_signal("OnSoulsModified")

# LEVELING
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

# VENDOR
func _on_vendor_item_selected(itemData):
	if itemData is AbilityData:
		add_ability(itemData)
	elif itemData is SpecialData:
		add_special(itemData)
	elif itemData is PassiveData:
		add_passive(itemData)
	elif itemData is ItemData:
		cell.room.generate_and_consume_item(self, itemData.id)

# SKIP_TURN MANAGEMENT
var _lastSkipTurn:int = -1
const SKIP_TURN_COOLDOWN:int = 5

func skip_turn():
	_lastSkipTurn = GameGlobals.dungeon.turnsTaken
	super.skip_turn()

func can_skip_turn():
	return _lastSkipTurn==-1 or (GameGlobals.dungeon.turnsTaken - _lastSkipTurn > SKIP_TURN_COOLDOWN)

func get_skip_turn_cooldown():
	return SKIP_TURN_COOLDOWN - (GameGlobals.dungeon.turnsTaken - _lastSkipTurn) + 1

# SPECIAL
func _on_special_pressed(special:Special):
	if special.try_activate():
		pass
	else:
		CombatEventManager.emit_signal("OnPlayerSpecialAbilityFailedToActivate", special)

# DUNGEON MODIFIERS
func add_dungeon_modifier(dungeonModifierData:DungeonModifierData):
	super.add_dungeon_modifier(dungeonModifierData)

	if dungeonModifierData.dungeonStartSouls>0:
		gain_souls(dungeonModifierData.dungeonStartSouls)

	if dungeonModifierData.vendorCostMultiplier!=0:
		_currentVendorCostMultiplier = _currentVendorCostMultiplier + dungeonModifierData.vendorCostMultiplier

func get_current_vendorcost_multiplier():
	return _currentVendorCostMultiplier
