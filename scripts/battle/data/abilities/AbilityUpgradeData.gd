
class_name AbilityUpgradeData

"""
{
    "id": "ABILITY_PROTECTION_PUSHBACK",
    "character": "KNIGHT",
    "name": "Protection Pushback",
    "description": "Push back any enemies that hit the player while [Protected] by 1 tile",
    "abilityUpgrades": [
        {
            "type": "ADD_LINKED_PASSIVE",
            "params": {
                "keyword": "PROTECTION",
                "passiveId": "PROTECTION_PUSHBACK"
            }
        }
    ]
}
"""

var type:String
var params:Dictionary

func _init(dataJS):
	type = dataJS["type"]
	params = dataJS["params"]
