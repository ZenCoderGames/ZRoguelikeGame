
class_name SpellData

"""{
    "id": "LIGHTNING_BOLT",
    "cooldown": 10,
    "timeline": [
        {
            "type": "FIND_TARGETS",
            "params": {
                "range": 1,
                "maxTargets": 1
            }
        },
        {
            "type": "DO_DAMAGE_TO_TARGETS",
            "params": {
                "damage": 30
            }
        }
    ]
}"""

var id:String
var cooldown:int
var timeline:Array

func _init(spellDataJS):
    id = spellDataJS["id"]
    cooldown = spellDataJS["cooldown"]
    var timelineJSList = spellDataJS["timeline"]
    for actionJS in timelineJSList:
        var newActionData:ActionData = ActionDataTypes.create(actionJS)
        if newActionData!=null:
            timeline.append(newActionData)