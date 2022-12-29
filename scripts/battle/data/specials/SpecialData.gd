
class_name SpecialData

"""
"special": {
	"id": "KNIGHT_SPECIAL",
	"description": "5 successful attacks charges up the ability. On use, grants the player a [Barrier]",
	"condition": ["ON_POST_HIT"],
	"count": 5,
	"timeline": [
		{
			"type": "APPLY_STATUS_EFFECT",
			"params": {
				"statusEffectId": "BARRIER",
				"target": "SELF"
			}
		}
	]
}
"""

var id:String
var description:String
var triggerConditions:Array
var count:int
var itemsGranted:Array
var timeline:Array

enum EXECUTE_CONDITION { NONE, NEARBY_ENEMY }
var executeCondition:int

func _init(dataJS):
	id = dataJS["id"]
	description = dataJS["description"]
	count = dataJS["count"]

	var conditionsJSList = dataJS["conditions"]
	for conditionStr in conditionsJSList:
		if Constants.TRIGGER_CONDITION.has(conditionStr):
			triggerConditions.append(Constants.TRIGGER_CONDITION.get(conditionStr))
		else:
			print("ERROR: Invalid Condition Type For PassiveData - ", conditionStr)

	var actionsJSList = dataJS["timeline"]
	for actionJS in actionsJSList:
		var actionData:ActionData = ActionDataTypes.create(actionJS)
		if actionData!=null:
			timeline.append(actionData)

	executeCondition = EXECUTE_CONDITION.get(dataJS["executeCondition"])
