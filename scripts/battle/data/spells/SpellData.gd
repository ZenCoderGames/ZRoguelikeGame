
class_name SpellData

"""{
    "id": "LIGHTNING_BOLT",
    "staminaCost": 2,
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
var staminaCost:int
var timeline:Array

func _init(spellDataJS):
    id = spellDataJS["id"]
    staminaCost = spellDataJS["staminaCost"]
    var timelineJSList = spellDataJS["timeline"]
    for actionJS in timelineJSList:
        var newActionData:ActionData = ActionDataTypes.create(actionJS)
        if newActionData!=null:
            timeline.append(newActionData)