class_name StatModifier

var type:int
var baseValue:int
var value:int

func _init(statModifierData):
    type = statModifierData.type
    value = statModifierData.value
    baseValue = statModifierData.baseValue

func modify(stat):
    stat.value = stat.value + value
    stat.baseValue = stat.baseValue + baseValue