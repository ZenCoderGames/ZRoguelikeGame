class_name StatusEffect

var character
var data:StatusEffectData

var instanceCount:int

func _init(parentChar, statusEffectData:StatusEffectData):
	character = parentChar
	data = statusEffectData
	instanceCount = data.instanceCount

	for actionData in data.startTimeline:
		var action:Action = ActionTypes.create(actionData, character)
		if(action!=null):
			action.execute()

	CombatEventManager.register_for_conditional_events(data.triggerConditions, self, character)

func activate_on_character_move(x, y):
	activate()

func activate_on_target_or_item(targetOrSpell):
	activate()

func activate_on_attacker(attacker, defender, data):
	if character==attacker:
		activate()

func activate_on_defender(attacker, defender, data):
	if character==defender:
		activate()	

func activate():
	instanceCount = instanceCount - 1
	_check_for_completion()

func _check_for_completion():
	if instanceCount==0:
		_clean_up()

func _clean_up():
	character.remove_status_effect(self)

	for actionData in data.endTimeline:
		var action:Action = ActionTypes.create(actionData, character)
		if(action!=null):
			action.execute()
