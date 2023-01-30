class_name PassiveData

var id:String
var name:String
var description:String
var triggerConditions:Array
var triggerConditionParams:Dictionary
var timeline:Array
var triggerCount:int
var resetCountOnActivate:bool
var dontDisplayInUI:bool

func _init(dataJS):
	id = dataJS["id"]
	name = dataJS["name"]
	description = dataJS["description"]
	dontDisplayInUI = Utils.get_data_from_json(dataJS, "dontDisplayInUI", false)

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
		if conditionParams.has("enemyStatusEffectId"):
			triggerConditionParams["enemyStatusEffectId"] = conditionParams["enemyStatusEffectId"]

	var actionsJSList = dataJS["timeline"]
	for actionJS in actionsJSList:
		var actionData:ActionData = ActionDataTypes.create(actionJS)
		if actionData!=null:
			timeline.append(actionData)

	triggerCount = Utils.get_data_from_json(dataJS, "triggerCount", 0)
	resetCountOnActivate = Utils.get_data_from_json(dataJS, "resetCountOnActivate", false)

func get_display_name():
	return name

func get_description():
	return description
