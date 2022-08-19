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

	if data.triggerConditions.has(Constants.TRIGGER_CONDITION.ON_POST_HIT):
		Dungeon.battleInstance.hitResolutionManager.connect("OnPostHit", self, "_on_character_post_hit")

func _on_character_post_hit(attacker, defender, damage):
	if character==attacker:
		_trigger_timeline()

func _trigger_timeline():
	for action in timelineActions:
		action.execute()
