
class_name ActionAddStatModifierData extends ActionData

const ID:String = "ADD_STAT_MODIFIER"

var statModifiers:Array

func _init(dataJS):
	super(dataJS)
	var modifierJSList:Array = dataJS["params"]["statModifiers"]
	for modifierJS in modifierJSList:
		var statModifierData = StatModifierData.new(modifierJS)
		statModifiers.append(statModifierData)
