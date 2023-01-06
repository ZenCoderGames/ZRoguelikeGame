class_name Passive

var character
var data:PassiveData
var timelineActions:Array = []
var _combatEventReceiver:CombatEventReceiver
var _triggerCount:int
var _count:int

func _init(parentChar, passiveData:PassiveData):
	character = parentChar
	data = passiveData
	_triggerCount = data.triggerCount
	_count = 0

	for actionData in data.timeline:
		var action:Action = ActionTypes.create(actionData, character)
		if(action!=null):
			timelineActions.append(action)

	if data.triggerConditions.size()>0:
		_combatEventReceiver = CombatEventReceiver.new(data.triggerConditions, data.triggerConditionParams, character, funcref(self, "on_event_triggered"))
	else:
		activate()

func on_event_triggered():
	attempt_activate()

func attempt_activate():
	if _triggerCount==0:
		activate()
	else:
		_count = _count + 1
		if _count>=_triggerCount:
			activate()

func activate():
	for action in timelineActions:
		action.execute()
	
	if data.resetCountOnActivate:
		_count = 0
