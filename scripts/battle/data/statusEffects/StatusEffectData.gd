class_name StatusEffectData

var id:String
var name:String
var description:String
var instanceCount:int
var triggerConditions:Array

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

    var actionsJSList = dataJS["startTimeline"]
    for actionJS in actionsJSList:
        startTimeline.append(ActionDataTypes.create(actionJS))

    actionsJSList = dataJS["endTimeline"]
    for actionJS in actionsJSList:
        endTimeline.append(ActionDataTypes.create(actionJS))

func get_display_name():
    return name

func get_description():
    return description