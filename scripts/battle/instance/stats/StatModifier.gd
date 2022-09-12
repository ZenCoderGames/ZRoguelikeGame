class_name StatModifier

var type:int
var baseValue:int

func _init(statModifierData):
    type = statModifierData.type
    baseValue = statModifierData.baseValue