class_name Ability

var character
var data:AbilityData
var timelineActions:Array = []

func _init(parentChar, abilityData:AbilityData):
	character = parentChar
	data = abilityData

	for actionData in data.timeline:
		var action:Action = ActionTypes.create(actionData, character)
		if(action!=null):
			timelineActions.append(action)

	activate()

func activate():
	for action in timelineActions:
		action.execute()
