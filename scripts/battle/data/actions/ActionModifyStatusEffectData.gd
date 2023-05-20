
class_name ActionModifyStatusEffectData extends ActionData

var ActionDataTypes = load("res://scripts/battle/data/actions/ActionDataTypes.gd")

const ID:String = "MODIFY_STATUS_EFFECT"

var statusEffectId:String
var instanceCountModifier:int

var startTimeline:Array
var endTimeline:Array

func _init(dataJS):
	super(dataJS)
	statusEffectId = dataJS["params"]["statusEffectId"]
	instanceCountModifier = Utils.get_data_from_json(dataJS["params"], "instanceCountModifier", 0)

	if params.has("startTimeline"):
		var actionsJSList = params["startTimeline"]
		for actionJS in actionsJSList:
			var actionData:ActionData = ActionDataTypes.create(actionJS)
			if actionData!=null:
				startTimeline.append(actionData)

	if params.has("endTimeline"):
		var actionsJSList = params["endTimeline"]
		for actionJS in actionsJSList:
			var actionData:ActionData = ActionDataTypes.create(actionJS)
			if actionData!=null:
				endTimeline.append(actionData)
