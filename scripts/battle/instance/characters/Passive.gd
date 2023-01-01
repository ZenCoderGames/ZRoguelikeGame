class_name Passive

var character
var data:PassiveData
var timelineActions:Array = []
var _combatEventReceiver:CombatEventReceiver

func _init(parentChar, passiveData:PassiveData):
	character = parentChar
	data = passiveData

	for actionData in data.timeline:
		var action:Action = ActionTypes.create(actionData, character)
		if(action!=null):
			timelineActions.append(action)

	_combatEventReceiver = CombatEventReceiver.new(data.triggerConditions, data.triggerConditionParams, character, funcref(self, "on_event_triggered"))

func on_event_triggered():
	activate()

func activate():
	for action in timelineActions:
		action.execute()
