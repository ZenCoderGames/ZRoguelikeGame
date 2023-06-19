class_name StatusEffectData

var id:String
var name:String
var description:String
var instanceCount:int
var triggerConditions:Array
var triggerConditionParams:Dictionary
var forceCompleteTriggerConditions:Array
var forceCompleteTriggerConditionParams:Dictionary

var startTimeline:Array
var endTimeline:Array

func _init(dataJS):
	id = dataJS["id"]
	name = dataJS["name"]
	description = dataJS["description"]

	instanceCount = dataJS["instanceCount"]

	var conditionsJSList = dataJS["endConditions"]
	for conditionStr in conditionsJSList:
		if Constants.TRIGGER_CONDITION.has(conditionStr):
			triggerConditions.append(Constants.TRIGGER_CONDITION.get(conditionStr))
		else:
			print("ERROR: Invalid Condition Type For StatusEffectData - ", conditionStr)

	if dataJS.has("endConditionParams"):
		var conditionParams = dataJS["endConditionParams"]
		if conditionParams.has("statusEffectId"):
			triggerConditionParams["statusEffectId"] = conditionParams["statusEffectId"]

	if dataJS.has("forceEndConditions"):
		conditionsJSList = dataJS["forceEndConditions"]
		for conditionStr in conditionsJSList:
			if Constants.TRIGGER_CONDITION.has(conditionStr):
				forceCompleteTriggerConditions.append(Constants.TRIGGER_CONDITION.get(conditionStr))
			else:
				print("ERROR: Invalid Force End Condition Type For StatusEffectData - ", conditionStr)

	if dataJS.has("forceEndConditionParams"):
		var conditionParams = dataJS["forceEndConditionParams"]
		if conditionParams.has("statusEffectId"):
			forceCompleteTriggerConditionParams["statusEffectId"] = conditionParams["statusEffectId"]

	if dataJS.has("startTimeline"):
		var actionsJSList = dataJS["startTimeline"]
		for actionJS in actionsJSList:
			var actionData:ActionData = ActionDataTypes.create(actionJS)
			if actionData!=null:
				startTimeline.append(actionData)

	if dataJS.has("endTimeline"):
		var actionsJSList = dataJS["endTimeline"]
		for actionJS in actionsJSList:
			var actionData:ActionData = ActionDataTypes.create(actionJS)
			if actionData!=null:
				endTimeline.append(actionData)

func get_display_name():
	return name

func get_description():
	return description
