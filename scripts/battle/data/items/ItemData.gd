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
var fullDescription:String
var path:String
var statDataList:Array
var statModifierDataList:Array

enum ITEM_TYPE { WEAPON, ARMOR, RUNE, CONSUMABLE, SPELL }
var type:int

var tier:int

var spellId:String
var passiveId:String
var statusEffectId:String

var maxCount:int

var disable:bool

func _init(itemDataJS):
	id = itemDataJS["id"]
	displayName = itemDataJS["name"]
	description = itemDataJS["description"]
	fullDescription = itemDataJS["fullDescription"]
	path = itemDataJS["path"]
	tier = itemDataJS["tier"]
	maxCount =  Utils.get_data_from_json(itemDataJS, "maxCount", 1)

	var itemType = itemDataJS["type"]
	if ITEM_TYPE.has(itemType):
		type = ITEM_TYPE.get(itemType)
	else:
		print("ERROR: Invalid Item Type - ", itemType)

	if itemDataJS.has("stats"):
		var statDataJSList = itemDataJS["stats"]
		for statDataJS in statDataJSList:
			var statData:StatData = StatData.new()
			statData.init_from_json(statDataJS)
			statDataList.append(statData)

	if itemDataJS.has("statModifiers"):
		var statModifierDataJSList = itemDataJS["statModifiers"]
		for statModifierDataJS in statModifierDataJSList:
			statModifierDataList.append(StatModifierData.new(statModifierDataJS))
			
	disable = Utils.get_data_from_json(itemDataJS, "disable", false)
	spellId = Utils.get_data_from_json(itemDataJS, "spellId", "")
	passiveId = Utils.get_data_from_json(itemDataJS, "passiveId", "")
	statusEffectId = Utils.get_data_from_json(itemDataJS, "statusEffectId", "")

func is_weapon():
	return type == ITEM_TYPE.WEAPON

func is_armor():
	return type == ITEM_TYPE.ARMOR

func is_rune():
	return type == ITEM_TYPE.RUNE

func is_gear():
	return is_weapon() or is_armor() or is_rune()

func is_consumable():
	return type == ITEM_TYPE.CONSUMABLE

func is_spell():
	return type == ITEM_TYPE.SPELL

func get_type_string():
	if is_weapon():
		return "Weapon"
	elif is_armor():
		return "Armor"
	elif is_rune():
		return "Rune"
	elif is_consumable():
		return "Consumable"
	elif is_spell():
		return "Spell"
	
	return "None"
