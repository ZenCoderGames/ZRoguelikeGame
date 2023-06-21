
class_name StatusEffectModifier

var _data:ActionModifyStatusEffectData 
var statusEffectId:String
var instanceCounterModifier:int

func _init(data:ActionModifyStatusEffectData):
	_data = data
	statusEffectId = data.statusEffectId
	instanceCounterModifier = data.instanceCountModifier

func execute_start_timeline_if_exists(character):
	if _data.startTimeline.size()>0:
		for actionData in _data.startTimeline:
			var action:Action = ActionTypes.create(actionData, character)
			if(action!=null) && action.can_execute():
				action.execute()

func execute_end_timeline_if_exists(character):
	if _data.endTimeline.size()>0:
		for actionData in _data.endTimeline:
			var action:Action = ActionTypes.create(actionData, character)
			if(action!=null) && action.can_execute():
				action.execute()
