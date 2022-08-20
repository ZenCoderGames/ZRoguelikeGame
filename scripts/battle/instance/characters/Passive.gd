class_name Passive

var character
var data:PassiveData
var timelineActions:Array = []

func _init(parentChar, passiveData:PassiveData):
	character = parentChar
	data = passiveData

	for actionData in data.timeline:
		var action:Action = ActionTypes.create(actionData, character)
		if(action!=null):
			timelineActions.append(action)

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
	for action in timelineActions:
		action.execute()
