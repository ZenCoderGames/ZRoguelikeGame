class_name CustomEncounterData

var id:String
var enemySpawnDataList:Array

func _init(dataJS):
    id = dataJS["id"]
    var enemyJSList:Array = dataJS["enemies"]
    for enemyJS in enemyJSList:
        enemySpawnDataList.append(EnemySpawnData.new(enemyJS))