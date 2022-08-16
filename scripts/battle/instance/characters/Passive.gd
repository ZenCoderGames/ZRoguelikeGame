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

	if data.triggerConditions.has(Constants.TRIGGER_CONDITION.ON_ATTACK_CONNECT):
		character.connect("OnAttackConnect", self, "_on_character_attack_connect")

func _on_character_attack_connect(defender, dmg):
	_trigger_timeline()

func _trigger_timeline():
	for action in timelineActions:
		action.execute()
