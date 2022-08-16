class_name StatusEffect

var character
var data:StatusEffectData

var instanceCount:int

func _init(parentChar, statusEffectData:StatusEffectData):
	character = parentChar
	data = statusEffectData
	instanceCount = data.instanceCount

	var timelineActions:Array = []
	for actionData in data.startTimeline:
		var action:Action = ActionTypes.create(actionData, character)
		if(action!=null):
			timelineActions.append(action)

	for action in timelineActions:
		action.execute()

	if data.triggerConditions.has(Constants.TRIGGER_CONDITION.ON_HIT):
		character.connect("OnHit", self, "_on_character_hit")

func _on_character_hit(attacker, dmg):
	instanceCount = instanceCount - 1
	_check_for_completion()

func _check_for_completion():
	if instanceCount==0:
		_clean_up()

func _clean_up():
	character.remove_status_effect(self)

	var timelineActions:Array = []
	for actionData in data.endTimeline:
		var action:Action = ActionTypes.create(actionData, character)
		if(action!=null):
			timelineActions.append(action)

	for action in timelineActions:
		action.execute()
