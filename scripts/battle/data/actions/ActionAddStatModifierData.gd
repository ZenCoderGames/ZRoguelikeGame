extends ActionData

class_name ActionAddStatModifierData

const ID:String = "ADD_STAT_MODIFIER"

var statusModifiers:Array

func _init(dataJS).(dataJS):
	var modifierJSList:Array = dataJS["params"]["statModifiers"]
	for modifierJS in modifierJSList:
		var statModifierData = StatModifierData.new(modifierJS)
		statusModifiers.append(statModifierData)
