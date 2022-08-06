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
var displayName:String
var description:String
var path:String
var statDataList:Array
var statModifierDataList:Array
var actionDataList:Array

enum ITEM_TYPE { EQUIPABLE, CONSUMABLE }
var type:int

var disable:bool

func _init(itemDataJS, actionDataMap):
	id = itemDataJS["id"]
	displayName = itemDataJS["name"]
	description = itemDataJS["description"]
	path = itemDataJS["path"]
	var itemType = itemDataJS["type"]
	if ITEM_TYPE.has(itemType):
		type = ITEM_TYPE.get(itemType)
	else:
		print("ERROR: Invalid Item Type - ", itemType)

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
			
	if itemDataJS.has("disable"):
		disable =  itemDataJS["disable"]

func is_equippable():
	return type == ITEM_TYPE.EQUIPABLE

func is_consumable():
	return type == ITEM_TYPE.CONSUMABLE
