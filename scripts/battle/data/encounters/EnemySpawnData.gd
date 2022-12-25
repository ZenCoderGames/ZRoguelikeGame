class_name EnemySpawnData

var type:String
var count:int

func _init(dataJS):
    type = dataJS["type"]
    count = dataJS["count"]