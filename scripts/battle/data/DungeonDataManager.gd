# Tracks all the data in the game
class_name DungeonDataManager

var complexStatDataMap = {}
var statusEffectDataMap = {}
var passiveDataMap = {}
var itemDataMap = {}
var itemDataList = []
var spellDataMap = {}

var characterDataDict = {}
var playerData:CharacterData
var heroDataList = []
var enemyDataList = []

var customEncounterDataDict = {}
var customEncounterDataList = []

var dungeonDataList:Array

var abilityDataDict = {}
var abilityList:Array

func _init():
	init_dungeon_data()
	init_complex_stats()
	init_status_effects()
	init_passives()
	init_spells()
	init_items("resource/data/items.json")
	init_items("resource/data/runeItems.json")
	init_items("resource/data/consumableItems.json")
	init_items("resource/data/spellItems.json")
	init_abilities()
	init_characters()
	init_encounters()

func on_character_chosen(charData):
	playerData = charData

# DUNGEONS
func init_dungeon_data():
	var data = Utils.load_data_from_file("resource/data/dungeons.json")
	var dungeonDataJSList:Array = data["dungeons"]
	for dungeonDataJS in dungeonDataJSList:
		var newDungeonData = DungeonData.new(dungeonDataJS)
		dungeonDataList.append(newDungeonData)

func get_max_levels():
	return GameGlobals.dataManager.dungeonDataList.size()

func init_status_effects():
	var data = Utils.load_data_from_file("resource/data/statusEffects.json")
	var statusEffectDataJSList:Array = data["statusEffects"]
	for statusEffectDataJS in statusEffectDataJSList:
		var newStatusEffectData = StatusEffectData.new(statusEffectDataJS)
		statusEffectDataMap[newStatusEffectData.id] = newStatusEffectData

func get_status_effect_data(id):
	return statusEffectDataMap[id]

func init_passives():
	var data = Utils.load_data_from_file("resource/data/passives.json")
	var passiveDataJSList:Array = data["passives"]
	for passiveDataJS in passiveDataJSList:
		var newPassiveData = PassiveData.new(passiveDataJS)
		passiveDataMap[newPassiveData.id] = newPassiveData

func get_passive_data(id):
	if passiveDataMap.has(id):
		return passiveDataMap[id]
	else:
		print("ERROR: INVALID PASSIVE ID Requested: " + id)
		return null

func init_items(itemLocation:String):
	var data = Utils.load_data_from_file(itemLocation)
	var itemDataJSList:Array = data["items"]
	for itemDataJS in itemDataJSList:
		var newItemData = ItemData.new(itemDataJS)
		if !newItemData.disable:
			itemDataMap[newItemData.id] = newItemData
			itemDataList.append(newItemData)

func get_item_data(id):
	if itemDataMap.has(id):
		return itemDataMap[id]
		
	print("Invalid Item ID:", id)
	return null

func init_characters():
	var data = Utils.load_data_from_file("resource/data/characters.json")
	var heroDataJSList:Array = data["characters"]["heroes"]
	for heroDataJS in heroDataJSList:
		var newCharData = CharacterData.new(heroDataJS)
		heroDataList.append(newCharData)
		characterDataDict[newCharData.id] = newCharData
	var enemyDataJSList:Array = data["characters"]["enemies"]
	for enemyDataJS in enemyDataJSList:
		var newCharData = CharacterData.new(enemyDataJS)
		if !newCharData.disable:
			enemyDataList.append(newCharData)
		characterDataDict[newCharData.id] = newCharData
		
	playerData = characterDataDict["PALADIN"]

func get_random_enemy_data():
	return enemyDataList[randi() % enemyDataList.size()]

func get_enemy_data(enemyId):
	return characterDataDict[enemyId]

func get_random_item_data():
	return itemDataList[randi() % itemDataList.size()]

func init_spells():
	var data = Utils.load_data_from_file("resource/data/spells.json")
	var spellDataJSList:Array = data["spells"]
	for spellDataJS in spellDataJSList:
		var newSpellData:SpellData = SpellData.new(spellDataJS)
		spellDataMap[newSpellData.id] = newSpellData

func get_spell_data(spellId):
	if spellDataMap.has(spellId):
		return spellDataMap[spellId]

	print("Invalid Spell Id: ", spellId)
	return null

func init_complex_stats():
	var data = Utils.load_data_from_file("resource/data/complexStats.json")
	var complexStatsJSList:Array = data["complexStats"]
	for complexStatDataJS in complexStatsJSList:
		var complexStatData:ComplexStatData = ComplexStatData.new(complexStatDataJS)
		complexStatDataMap[complexStatData.statType] = complexStatData

func is_complex_stat_data(statType):
	return complexStatDataMap.has(statType)

func get_complex_stat_data(statType):
	if complexStatDataMap.has(statType):
		return complexStatDataMap[statType]

	print("Invalid Complex Stat Data: ", statType)
	return null

func init_encounters():
	var data = Utils.load_data_from_file("resource/data/encounters.json")
	var encounterJSList:Array = data["custom"]
	for encounterJS in encounterJSList:
		var newCustomEncounter = CustomEncounterData.new(encounterJS)
		customEncounterDataDict[newCustomEncounter.id] = newCustomEncounter
		customEncounterDataList.append(newCustomEncounter)

func get_custom_encounter(encounterId):
	if customEncounterDataDict.has(encounterId):
		return customEncounterDataDict[encounterId]

	print("Invalid Custom Encounter Data: ", encounterId)
	return null

func init_abilities():
	var data = Utils.load_data_from_file("resource/data/abilities.json")
	var abilityDataJSList:Array = data["abilities"]
	for abilityDataJS in abilityDataJSList:
		var newAbilityData = AbilityData.new(abilityDataJS)
		abilityDataDict[newAbilityData.id] = newAbilityData
		abilityList.append(newAbilityData)

func get_ability_data(id):
	if abilityDataDict.has(id):
		return abilityDataDict[id]
	else:
		print("ERROR: INVALID ABILITY ID Requested: " + id)
		return null
