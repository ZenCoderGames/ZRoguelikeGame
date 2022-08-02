class_name ItemData

"""{
			"id": "SWORD_00",
			"name": "Basic Sword",
			"description": "Just a simple sword",
			"actions": [
				{
					"actionId": "MELEE_ATTACK",
					"overrideParams": {
						"damageBonus": 2
					}
				}
			]
		}"""

var id:String
var name:String
var description:String
var statDataList:Array
var statModifierDataList:Array
var actionDataList:Array

enum STAT_TYPE { EQUIPABLE, CONSUMABLE }
var type:int

func _init(itemDataJS, actionDataMap):
	id = itemDataJS["id"]
	name = itemDataJS["name"]
	description = itemDataJS["description"]

	if itemDataJS.has("stats"):
		var statDataJSList = itemDataJS["stats"]
		for statDataJS in statDataJSList:
			statDataList.append(StatData.new(statDataJS))

	if itemDataJS.has("statModifiers"):
		var statModifierDataJSList = itemDataJS["statModifiers"]
		for statModifierDataJS in statModifierDataJSList:
			statModifierDataList.append(StatModifierData.new(statModifierDataJS))
	
	if itemDataJS.has("actions"):
		var actionDataIdJSList = itemDataJS["actions"]
		for actionDataIdJS in actionDataIdJSList:
			actionDataList.append(actionDataMap[actionDataIdJS])
