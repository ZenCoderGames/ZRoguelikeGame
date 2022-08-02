class_name Stat

var type:int
var baseValue:int
var value:int

func _init(statData):
    type = statData.type
    baseValue = statData.value
    value = statData.value