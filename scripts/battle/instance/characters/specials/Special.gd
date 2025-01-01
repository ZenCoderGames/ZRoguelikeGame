class_name Special

var character
var data:SpecialData
var timelineActions:Array = []
var currentCount:int
var isAvailable:bool
var _combatEventReceiver:CombatEventReceiver
var _specialModifierList:Array = []
var _cooldownTimer:int

var _blockActivation:bool

signal OnActivated()
signal OnProgress(progress)
signal OnReady(special)
signal OnReset(special)
signal OnCountIncremented(special)
signal OnCountUpdated(currentResourceCount)
signal OnSpecialModifierAdded()
signal OnSpecialModifierRemoved()

func _init(parentChar,specialData:SpecialData):
	character = parentChar
	data = specialData
	_reset()

	for actionData in data.timeline:
		var action:Action = ActionTypes.create(actionData, character)
		if(action!=null):
			timelineActions.append(action)

	if specialData.useCustomConditions:
		if data.triggerConditions.size()>0:
			_combatEventReceiver = CombatEventReceiver.new(data.triggerConditions, data.triggerConditionParams, character, Callable(self, "on_event_triggered"))
		else:
			_set_ready()
	else:
		character.connect("OnStatChanged",Callable(self,"_on_player_stat_changed"))
		check_for_ready_with_energy()

	_cooldownTimer = -1
	
	CombatEventManager.connect("OnPlayerSpecialAbilityActivated",Callable(self,"_on_special_activated"))
	CombatEventManager.connect("OnPlayerSpecialAbilityCompleted",Callable(self,"_on_special_completed"))
	CombatEventManager.connect("OnPlayerSpecialSelectionCompleted",Callable(self,"_on_special_selection_completed"))

func on_event_triggered():
	_increment()

func _increment():
	if !isAvailable:
		_updateCount(currentCount + 1)
		check_for_ready()
	emit_signal("OnCountIncremented", self)

func check_for_ready():
	var maxCount:int = get_max_count()
	emit_signal("OnProgress", (float(currentCount))/(float(maxCount)))
	if currentCount==maxCount:
		_set_ready()

func _on_player_stat_changed(_character:Character):
	check_for_ready_with_energy()

func check_for_ready_with_energy():
	var currentEnergy:int = character.get_energy()
	var energyNeededToActivate:int = get_max_count()
	emit_signal("OnProgress", (float(currentEnergy))/(float(energyNeededToActivate)))
	_updateCount(currentEnergy)
	if currentEnergy>=energyNeededToActivate:
		_set_ready()
	else:
		# TODO: Let UI know to reset state (Usually when another special has used up energy)
		pass

func _set_ready():
	isAvailable = true
	emit_signal("OnReady", self)
	CombatEventManager.emit_signal("OnPlayerSpecialAbilityReady", self)

func _is_execute_condition_met():
	if !data.useCustomConditions:
		return true

	if data.executeCondition == SpecialData.EXECUTE_CONDITION.NONE:
		return true

	if data.executeCondition == SpecialData.EXECUTE_CONDITION.NEARBY_ENEMY:
		var adjacentChars:Array = GameGlobals.dungeon.get_adjacent_characters(character, Constants.RELATIVE_TEAM.ENEMY, 1)
		return adjacentChars.size()>0

	if data.executeCondition == SpecialData.EXECUTE_CONDITION.NO_NEARBY_ENEMY:
		var adjacentChars:Array = GameGlobals.dungeon.get_adjacent_characters(character, Constants.RELATIVE_TEAM.ENEMY, 1)
		return adjacentChars.size()==0

	return false

func is_on_cooldown():
	return _cooldownTimer>=0 && GameGlobals.dungeon.turnsTaken-_cooldownTimer<data.cooldown

func get_remaining_cooldown():
	if _cooldownTimer==-1:
		return 0

	return data.cooldown - (GameGlobals.dungeon.turnsTaken-_cooldownTimer)

func try_activate():
	if _blockActivation:
		return false

	if is_on_cooldown():
		return false

	if _is_execute_condition_met():
		_activate()
		return true
	
	return false

func _activate():
	emit_signal("OnActivated")
	character.emit_signal("OnAnySpecialActivated")
	CombatEventManager.emit_signal("OnPlayerSpecialAbilityActivated", self)

	if !data.useCustomConditions:
		character.consume_energy(get_max_count())

	if data.hasSelection:
		_start_selection()
	else:
		_start_activate_timeline()

var InSelectionMode:bool
var _selectedCells:Array
var _selectedVFX:Array

func _start_selection():
	InSelectionMode = true
	if data.selectionType == SpecialData.SELECTION_TYPE.DIRECTIONAL:
		var room:DungeonRoom = GameGlobals.dungeon.player.currentRoom
		room.darken_all_cells()
		var playerCell:DungeonCell = GameGlobals.dungeon.player.cell
		playerCell.lighten()

		# right
		var cell:DungeonCell = GameGlobals.dungeon.player.currentRoom.get_cell(playerCell.row, playerCell.col + 1)
		var vfx = room.generate_vfx("entity/effects/Effect_Arrow_Right.tscn", cell, 0.35)
		_selectedCells.append(cell)
		_selectedVFX.append(vfx)
		# left
		cell = GameGlobals.dungeon.player.currentRoom.get_cell(playerCell.row, playerCell.col - 1)
		vfx = room.generate_vfx("entity/effects/Effect_Arrow_Left.tscn", cell, 0.35)
		_selectedCells.append(cell)
		_selectedVFX.append(vfx)
		# up
		cell = GameGlobals.dungeon.player.currentRoom.get_cell(playerCell.row - 1, playerCell.col)
		vfx = room.generate_vfx("entity/effects/Effect_Arrow_Up.tscn", cell, 0.35)
		_selectedCells.append(cell)
		_selectedVFX.append(vfx)
		# down
		cell = GameGlobals.dungeon.player.currentRoom.get_cell(playerCell.row + 1, playerCell.col)
		vfx = room.generate_vfx("entity/effects/Effect_Arrow_Down.tscn", cell, 0.35)
		_selectedCells.append(cell)
		_selectedVFX.append(vfx)

		CombatEventManager.emit_signal("OnPlayerSpecialSelectionActivated", self)

func _start_activate_timeline():
	for action in timelineActions:
		if action.can_execute():
			action.execute()

	if data.removeAfterExecute:
		character.remove_special(data.id)
	else:
		_reset()

	_cooldownTimer = GameGlobals.dungeon.turnsTaken + 1

	CombatEventManager.emit_signal("OnPlayerSpecialAbilityCompleted", self)

func _reset():
	isAvailable = false
	_updateCount(0)
	emit_signal("OnReset", self)

func force_ready():
	_updateCount(get_max_count())
	check_for_ready()

func get_current_count()->int:
	return currentCount

func get_max_count()->int:
	var maxCount:int = data.count
	for specialModifier in _specialModifierList:
		maxCount = maxCount + specialModifier.countModifier
	return maxCount

func _updateCount(newCount:int):
	currentCount = newCount
	emit_signal("OnCountUpdated", currentCount)

func get_remaining_count():
	return get_max_count() - currentCount

# MODIFIERS
func add_modifier(specialModifier:SpecialModifier):
	_specialModifierList.append(specialModifier)
	check_for_ready()
	emit_signal("OnSpecialModifierAdded")

func remove_modifier(_specialId:String):
	for i in range(_specialModifierList.size() - 1, -1, -1):
		_specialModifierList.remove_at(i)
	emit_signal("OnSpecialModifierRemoved")

# OTHER SPECIALS
func _on_special_activated(_special:Special):
	_blockActivation = true

func _on_special_completed(_special:Special):
	_blockActivation = false

func _on_special_selection_completed(special:Special, dirn:String):
	if special == self:
		if dirn==Constants.INPUT_MOVE_LEFT:
			character.specialSelectedDirnX = -1
		elif dirn==Constants.INPUT_MOVE_RIGHT:
			character.specialSelectedDirnX = 1
		elif dirn==Constants.INPUT_MOVE_UP:
			character.specialSelectedDirnY = -1
		elif dirn==Constants.INPUT_MOVE_DOWN:
			character.specialSelectedDirnY = 1
		_start_activate_timeline()

		# clean up
		var room:DungeonRoom = GameGlobals.dungeon.player.currentRoom
		room.lighten_all_cells()
		#var playerCell:DungeonCell = GameGlobals.dungeon.player.cell
		#playerCell.lighten()
		for i in range(_selectedCells.size()):
			room.destroy_vfx(_selectedVFX[i], _selectedCells[i])
		_selectedCells.clear()
		_selectedVFX.clear()

		character.specialSelectedDirnX = 0
		character.specialSelectedDirnY = 0
		InSelectionMode = false
		
