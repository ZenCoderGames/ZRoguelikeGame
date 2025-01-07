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
signal OnCountUpdated()
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
	emit_signal("OnCountUpdated")

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

# SELECTION
var InSelectionMode:bool
var _selectedCells:Array
var _selectedCellsLeft:Array
var _selectedCellsRight:Array
var _selectedCellsUp:Array
var _selectedCellsDown:Array
var _selectedVFX:Array

func _start_selection():
	InSelectionMode = true
	if data.selectionType == SpecialData.SELECTION_TYPE.DIRECTIONAL:
		var room:DungeonRoom = GameGlobals.dungeon.player.currentRoom
		room.darken_all_cells()
		var playerCell:DungeonCell = GameGlobals.dungeon.player.cell
		playerCell.lighten()

		# left
		for i in range(data.selectionRange):
			_highlight_selected_cell(_selectedCellsLeft, playerCell.row, playerCell.col - (i+1), false, "entity/effects/Effect_Arrow_Left.tscn")
		# right
		for i in range(data.selectionRange):
			_highlight_selected_cell(_selectedCellsRight, playerCell.row, playerCell.col + (i + 1), false, "entity/effects/Effect_Arrow_Right.tscn")
		# up
		for i in range(data.selectionRange):
			_highlight_selected_cell(_selectedCellsUp, playerCell.row - (i+1), playerCell.col, false, "entity/effects/Effect_Arrow_Up.tscn")
		# down
		for i in range(data.selectionRange):
			_highlight_selected_cell(_selectedCellsDown, playerCell.row + (i+1), playerCell.col, false, "entity/effects/Effect_Arrow_Down.tscn")
	elif data.selectionType == SpecialData.SELECTION_TYPE.DIRECTIONAL_CELL:
		var room:DungeonRoom = GameGlobals.dungeon.player.currentRoom
		room.darken_all_cells()
		var playerCell:DungeonCell = GameGlobals.dungeon.player.cell
		playerCell.lighten()

		# left
		for i in range(data.selectionRange):
			_highlight_selected_cell(_selectedCellsLeft, playerCell.row, playerCell.col - (i+1), true, "entity/effects/Effect_HighlightCell.tscn")
		# right
		for i in range(data.selectionRange):
			_highlight_selected_cell(_selectedCellsRight, playerCell.row, playerCell.col + (i + 1), true, "entity/effects/Effect_HighlightCell.tscn")
		# up
		for i in range(data.selectionRange):
			_highlight_selected_cell(_selectedCellsUp, playerCell.row - (i+1), playerCell.col, true, "entity/effects/Effect_HighlightCell.tscn")
		# down
		for i in range(data.selectionRange):
			_highlight_selected_cell(_selectedCellsDown, playerCell.row + (i+1), playerCell.col, true, "entity/effects/Effect_HighlightCell.tscn")

	CombatEventManager.emit_signal("OnPlayerSpecialSelectionActivated", self)

func _highlight_selected_cell(directionalCellArray:Array, row:int, col:int, lightenCell:bool, vfxPath:String):
	var room:DungeonRoom = GameGlobals.dungeon.player.currentRoom
	var cell:DungeonCell = GameGlobals.dungeon.player.currentRoom.get_cell(row, col)
	if cell!=null:
		var vfx = room.generate_vfx(vfxPath, cell, 0.35)
		directionalCellArray.append(cell)
		_selectedCells.append(cell)
		_selectedVFX.append(vfx)
		if lightenCell:
			cell.lighten()
		if cell.is_entity_type(Constants.ENTITY_TYPE.STATIC):
			vfx.self_modulate = Color.RED

func _on_special_selection_completed(special:Special, dirn:String):
	if special == self:
		if data.selectionType == SpecialData.SELECTION_TYPE.DIRECTIONAL:
			if dirn==Constants.INPUT_MOVE_LEFT:
				character.specialSelectedDirnX = -1
			elif dirn==Constants.INPUT_MOVE_RIGHT:
				character.specialSelectedDirnX = 1
			elif dirn==Constants.INPUT_MOVE_UP:
				character.specialSelectedDirnY = -1
			elif dirn==Constants.INPUT_MOVE_DOWN:
				character.specialSelectedDirnY = 1
		elif data.selectionType == SpecialData.SELECTION_TYPE.DIRECTIONAL_CELL:
			if dirn==Constants.INPUT_MOVE_LEFT:
				character.specialSelectedCells.append_array(_selectedCellsLeft)
			elif dirn==Constants.INPUT_MOVE_RIGHT:
				character.specialSelectedCells.append_array(_selectedCellsRight)
			elif dirn==Constants.INPUT_MOVE_UP:
				character.specialSelectedCells.append_array(_selectedCellsUp)
			elif dirn==Constants.INPUT_MOVE_DOWN:
				character.specialSelectedCells.append_array(_selectedCellsDown)

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
		_selectedCellsLeft.clear()
		_selectedCellsRight.clear()
		_selectedCellsUp.clear()
		_selectedCellsDown.clear()

		character.specialSelectedDirnX = 0
		character.specialSelectedDirnY = 0
		character.specialSelectedCells.clear()
		InSelectionMode = false
		
