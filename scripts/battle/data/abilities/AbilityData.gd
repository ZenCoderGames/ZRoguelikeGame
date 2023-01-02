
class_name AbilityData

"""
{
	"id": "ABILITY_PROTECTION_PUSHBACK",
	"characterId": "KNIGHT",
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

var id:String
var name:String
var description:String
var characterId:String
var abilityConditions:Array
var timeline:Array

func _init(dataJS):
	id = dataJS["id"]
	name = dataJS["name"]
	description = dataJS["description"]
	characterId = dataJS["characterId"]

	var actionsJSList = dataJS["timeline"]
	for actionJS in actionsJSList:
		var actionData:ActionData = ActionDataTypes.create(actionJS)
		if actionData!=null:
			timeline.append(actionData)

func get_display_name():
	return name

func get_description():
	return description
