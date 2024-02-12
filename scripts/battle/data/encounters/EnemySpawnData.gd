class_name EnemySpawnData

var type:String
var count:int
var isMiniboss:bool

func _init(dataJS):
    type = dataJS["type"]
    count = dataJS["count"]
    isMiniboss = Utils.get_data_from_json(dataJS, "isMiniboss", false)