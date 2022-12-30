class_name StatusEffect

var character
var data:StatusEffectData

var instanceCount:int
var _combatEventReceiver:CombatEventReceiver
var _forceCompleteCombatEventReceiver:CombatEventReceiver

func _init(parentChar, statusEffectData:StatusEffectData):
	character = parentChar
	data = statusEffectData
	instanceCount = data.instanceCount

	for actionData in data.startTimeline:
		var action:Action = ActionTypes.create(actionData, character)
		if(action!=null):
			action.execute()

	_combatEventReceiver = CombatEventReceiver.new(data.triggerConditions, character, funcref(self, "on_event_triggered"))
	if data.forceCompleteTriggerConditions.size()>0:
		_forceCompleteCombatEventReceiver = CombatEventReceiver.new(data.forceCompleteTriggerConditions, character, funcref(self, "on_force_complete_event_triggered"))

	var statusEffectModifierList:Array = character.get_status_effect_modifiers(data.id)
	for statusEffectModifier in statusEffectModifierList:
		instanceCount = instanceCount + statusEffectModifier.instanceCounterModifier
		statusEffectModifier.execute_start_timeline_if_exists(character)

func on_event_triggered():
	activate()
	
func on_force_complete_event_triggered():
	_force_complete()

func activate():
	instanceCount = instanceCount - 1
	_check_for_completion()

func _check_for_completion():
	if instanceCount==0:
		_clean_up()

func _force_complete():
	instanceCount = 0
	_clean_up()

func _clean_up():
	character.remove_status_effect(self)

	for actionData in data.endTimeline:
		var action:Action = ActionTypes.create(actionData, character)
		if(action!=null):
			action.execute()

	var statusEffectModifierList:Array = character.get_status_effect_modifiers(data.id)
	for statusEffectModifier in statusEffectModifierList:
		statusEffectModifier.execute_end_timeline_if_exists(character)
