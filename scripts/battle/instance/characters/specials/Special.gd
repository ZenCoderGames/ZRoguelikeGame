class_name Special

var character
var data:SpecialData
var timelineActions:Array = []
var currentCount:int
var isAvailable:bool
var _combatEventReceiver:CombatEventReceiver

signal OnSpecialCountUpdated(currentResourceCount)

func _init(parentChar,specialData:SpecialData):
	character = parentChar
	data = specialData
	_reset()

	for actionData in data.timeline:
		var action:Action = ActionTypes.create(actionData, character)
		if(action!=null):
			timelineActions.append(action)

	_combatEventReceiver = CombatEventReceiver.new(data.triggerConditions, data.triggerConditionParams, character, Callable(self, "on_event_triggered"))
	
	if parentChar is PlayerCharacter:
		CombatEventManager.connect("OnPlayerSpecialAbilityPressed",Callable(self,"try_activate"))

func on_event_triggered():
	_increment()

func _increment():
	_updateCount(currentCount + 1)
	check_for_ready()

func check_for_ready():
	var maxCount:int = _get_max_count()
	CombatEventManager.on_player_special_ability_progress((float(currentCount))/(float(maxCount)))
	if currentCount==maxCount:
		_set_ready()

func _set_ready():
	isAvailable = true
	CombatEventManager.on_player_special_ability_ready()

func _is_execute_condition_met():
	if data.executeCondition == SpecialData.EXECUTE_CONDITION.NONE:
		return true

	if data.executeCondition == SpecialData.EXECUTE_CONDITION.NEARBY_ENEMY:
		var adjacentChars:Array = GameGlobals.dungeon.get_adjacent_characters(character, Constants.RELATIVE_TEAM.ENEMY, 1)
		return adjacentChars.size()>0

	if data.executeCondition == SpecialData.EXECUTE_CONDITION.NO_NEARBY_ENEMY:
		var adjacentChars:Array = GameGlobals.dungeon.get_adjacent_characters(character, Constants.RELATIVE_TEAM.ENEMY, 1)
		return adjacentChars.size()==0

	return false

func try_activate():
	if _is_execute_condition_met():
		_activate()
		return true
	else:
		CombatEventManager.emit_signal("OnPlayerSpecialAbilityFailedToActivate")
		return false

func _activate():
	for action in timelineActions:
		if action.can_execute():
			action.execute()
	CombatEventManager.emit_signal("OnPlayerSpecialAbilityActivated")

	if data.removeAfterExecute:
		character.remove_special()
	else:
		_reset()

func _reset():
	isAvailable = false
	_updateCount(0)
	CombatEventManager.on_player_special_ability_reset()

func force_ready():
	_updateCount(_get_max_count())
	check_for_ready()

func _get_max_count()->int:
	var maxCount:int = data.count
	var specialModifierList:Array = character.get_special_modifiers(data.id)
	for specialModifier in specialModifierList:
		maxCount = maxCount + specialModifier.countModifier
	return maxCount

func _updateCount(newCount:int):
	currentCount = newCount
	emit_signal("OnSpecialCountUpdated", currentCount)
