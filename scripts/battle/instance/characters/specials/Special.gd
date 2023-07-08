class_name Special

var character
var data:SpecialData
var timelineActions:Array = []
var currentCount:int
var isAvailable:bool
var _combatEventReceiver:CombatEventReceiver

signal OnActivated()
signal OnProgress(progress)
signal OnReady()
signal OnReset()
signal OnCountIncremented()
signal OnCountUpdated(currentResourceCount)

func _init(parentChar,specialData:SpecialData):
	character = parentChar
	data = specialData
	_reset()

	for actionData in data.timeline:
		var action:Action = ActionTypes.create(actionData, character)
		if(action!=null):
			timelineActions.append(action)

	_combatEventReceiver = CombatEventReceiver.new(data.triggerConditions, data.triggerConditionParams, character, Callable(self, "on_event_triggered"))

func on_event_triggered():
	_increment()

func _increment():
	if !isAvailable:
		_updateCount(currentCount + 1)
		check_for_ready()
	emit_signal("OnCountIncremented")

func check_for_ready():
	var maxCount:int = get_max_count()
	emit_signal("OnProgress", (float(currentCount))/(float(maxCount)))
	if currentCount==maxCount:
		_set_ready()

func _set_ready():
	isAvailable = true
	emit_signal("OnReady")

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
	
	return false

func _activate():
	for action in timelineActions:
		if action.can_execute():
			action.execute()

	emit_signal("OnActivated")

	if data.removeAfterExecute:
		character.remove_special()
	else:
		_reset()

func _reset():
	isAvailable = false
	_updateCount(0)
	emit_signal("OnReset")

func force_ready():
	_updateCount(get_max_count())
	check_for_ready()

func get_max_count()->int:
	var maxCount:int = data.count
	var specialModifierList:Array = character.get_special_modifiers(data.id)
	for specialModifier in specialModifierList:
		maxCount = maxCount + specialModifier.countModifier
	return maxCount

func _updateCount(newCount:int):
	currentCount = newCount
	emit_signal("OnCountUpdated", currentCount)
