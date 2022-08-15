class_name PassiveData

var id:String
var triggerConditions:Array

var actions:Array

func _init(dataJS):
    id = dataJS["id"]

    var conditionsJSList = dataJS["conditions"]
    for conditionStr in conditionsJSList:
        if Constants.TRIGGER_CONDITION.has(conditionStr):
            triggerConditions.append(Constants.TRIGGER_CONDITION.get(conditionStr))
        else:
            print("ERROR: Invalid Condition Type For PassiveData - ", conditionStr)

    var actionsJSList = dataJS["actions"]
    for actionJS in actionsJSList:
        actions.append(ActionDataTypes.create(actionJS))