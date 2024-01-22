class_name Special

var character
var data:SpecialData
var timelineActions:Array = []
var currentCount:int
var isAvailable:bool
var _combatEventReceiver:CombatEventReceiver
var _specialModifierList:Array = []
var _cooldownTimer:int

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

func _on_player_stat_changed(character:Character):
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
	if is_on_cooldown():
		return false

	if _is_execute_condition_met():
		_activate()
		return true
	
	return false

func _activate():
	for action in timelineActions:
		if action.can_execute():
			action.execute()

	emit_signal("OnActivated")
	character.emit_signal("OnAnySpecialActivated")
	CombatEventManager.emit_signal("OnPlayerSpecialAbilityActivated", self)

	if data.removeAfterExecute:
		character.remove_special(data.id)
	else:
		_reset()

	if !data.useCustomConditions:
		character.consume_energy(get_max_count())

	_cooldownTimer = GameGlobals.dungeon.turnsTaken

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
