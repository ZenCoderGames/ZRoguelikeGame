
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
var name:String
var description:String
var soulCost:int
var useCustomConditions:bool
var triggerConditions:Array
var triggerConditionParams:Dictionary
var count:int
var cooldown:int
var itemsGranted:Array
var timeline:Array
var removeAfterExecute:bool
var hasSelection:bool
var selectionRange:int
var useDefenseSlot:bool

enum SELECTION_TYPE { NONE, DIRECTIONAL, DIRECTIONAL_CELL }
var selectionType:int

enum EXECUTE_CONDITION { NONE, NEARBY_ENEMY, NO_NEARBY_ENEMY }
var executeCondition:int

func _init(dataJS):
	id = dataJS["id"]
	name = dataJS["name"]
	description = dataJS["description"]
	count = Utils.get_data_from_json(dataJS, "count", 0)
	cooldown = Utils.get_data_from_json(dataJS, "cooldown", 2)
	soulCost = Utils.get_data_from_json(dataJS, "soulCost", 0)
	useCustomConditions = Utils.get_data_from_json(dataJS, "useCustomConditions", false)
	useDefenseSlot = Utils.get_data_from_json(dataJS, "useDefenseSlot", false)

	if dataJS.has("conditions"):
		var conditionsJSList = dataJS["conditions"]
		for conditionStr in conditionsJSList:
			if Constants.TRIGGER_CONDITION.has(conditionStr):
				triggerConditions.append(Constants.TRIGGER_CONDITION.get(conditionStr))
			else:
				print("ERROR: Invalid Condition Type For PassiveData - ", conditionStr)

	if dataJS.has("conditionParams"):
		var conditionParams = dataJS["conditionParams"]
		if conditionParams.has("statusEffectId"):
			triggerConditionParams["statusEffectId"] = conditionParams["statusEffectId"]

	var actionsJSList = dataJS["timeline"]
	for actionJS in actionsJSList:
		var actionData:ActionData = ActionDataTypes.create(actionJS)
		if actionData!=null:
			timeline.append(actionData)

	if dataJS.has("executeCondition"):
		executeCondition = EXECUTE_CONDITION.get(dataJS["executeCondition"])
	else:
		executeCondition = EXECUTE_CONDITION.NONE

	removeAfterExecute = Utils.get_data_from_json(dataJS, "removeAfterExecute", false)

	hasSelection = Utils.get_data_from_json(dataJS, "hasSelection", false)
	if dataJS.has("selectionType"):
		selectionType = SELECTION_TYPE.get(dataJS["selectionType"])
	else:
		selectionType = SELECTION_TYPE.NONE
	selectionRange = Utils.get_data_from_json(dataJS, "selectionRange", 1)
