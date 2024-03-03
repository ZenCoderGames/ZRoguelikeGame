# Tracks all the data in the game
class_name DungeonDataManager

var tutorialPickupDataMap = {}
var statusEffectDataMap = {}
var passiveDataMap = {}
var specialDataList = []
var specialDataMap = {}
var itemDataMap = {}
var itemDataList = []
var nonVendorItemDataList = []
var spellDataMap = {}
var vendorDataMap = {}
var vendorDataList = []

var characterDataDict = {}
var playerData:CharacterData
var heroDataList = []
var enemyDataList = []

var customEncounterDataDict = {}
var customEncounterDataList = []

var dungeonDataList:Array

var abilityDataDict = {}
var abilityList:Array

var dungeonModifierDict = {}
var levels:Array
var levelDict = {}

func _init():
	init_status_effects()
	init_passives()
	init_specials()
	#init_spells()
	init_items("resource/data/items.json")
	init_items("resource/data/runeItems.json")
	init_items("resource/data/consumableItems.json")
	#init_items("resource/data/spellItems.json")
	init_abilities("resource/data/abilities/abilities_shared.json")
	init_abilities("resource/data/abilities/abilities_paladin.json")
	init_abilities("resource/data/abilities/abilities_berserker.json")
	init_abilities("resource/data/abilities/abilities_assassin.json")
	init_characters()
	init_encounters()
	init_vendors("resource/data/vendors.json")
	init_encounters()
	init_tutorials()
	init_dungeonModifiers()
	init_levels()

func on_character_chosen(charData):
	playerData = charData

# DUNGEONS
func init_dungeon_data(levelData:LevelData):
	dungeonDataList.clear()
	var data = Utils.load_data_from_file(levelData.dungeonPath)
	var dungeonDataJSList:Array = data["dungeons"]
	for dungeonDataJS in dungeonDataJSList:
		var newDungeonData = DungeonData.new(dungeonDataJS)
		dungeonDataList.append(newDungeonData)

func get_max_levels():
	return dungeonDataList.size()

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

func init_specials():
	var data = Utils.load_data_from_file("resource/data/specials.json")
	var specialDataJSList:Array = data["specials"]
	for specialDataJS in specialDataJSList:
		var newSpecialData = SpecialData.new(specialDataJS)
		specialDataMap[newSpecialData.id] = newSpecialData

func get_special_data(id):
	if specialDataMap.has(id):
		return specialDataMap[id]
	else:
		print("ERROR: INVALID SPECIAL ID Requested: " + id)
		return null

func init_items(itemLocation:String):
	var data = Utils.load_data_from_file(itemLocation)
	var itemDataJSList:Array = data["items"]
	for itemDataJS in itemDataJSList:
		var newItemData = ItemData.new(itemDataJS)
		if !newItemData.disable:
			itemDataMap[newItemData.id] = newItemData
			itemDataList.append(newItemData)
			if !newItemData.onlyAtVendors:
				nonVendorItemDataList.append(newItemData)

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

func init_vendors(vendorLocation:String):
	var data = Utils.load_data_from_file(vendorLocation)
	var vendorDataJSList:Array = data["vendors"]
	for vendorDataJS in vendorDataJSList:
		var newVendorData = VendorData.new(vendorDataJS)
		if newVendorData.disable:
			continue
		vendorDataMap[newVendorData.id] = newVendorData
		vendorDataList.append(newVendorData)

func get_vendor_data(id):
	if vendorDataMap.has(id):
		return vendorDataMap[id]
		
	print("Invalid Vendor ID:", id)
	return null

func get_random_enemy_data():
	return enemyDataList[randi() % enemyDataList.size()]

func get_character_data(charId):
	return characterDataDict[charId]

func get_random_item_data():
	return nonVendorItemDataList[randi() % nonVendorItemDataList.size()]

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

func init_abilities(dataPath:String):
	var data = Utils.load_data_from_file(dataPath)
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

# TUTORIALS
func init_tutorials():
	var data = Utils.load_data_from_file("resource/data/tutorialPickups.json")
	var tutorialPickupDataJSList:Array = data["tutorialPickups"]
	for tutorialPickupDataJS in tutorialPickupDataJSList:
		var newTutorialPickupData = TutorialPickupData.new(tutorialPickupDataJS)
		tutorialPickupDataMap[newTutorialPickupData.id] = newTutorialPickupData

func get_tutorial_pickup_data(id):
	return tutorialPickupDataMap[id]

# DUNGEON MODIFIERS
func init_dungeonModifiers():
	var data = Utils.load_data_from_file("resource/data/dungeonModifiers.json")
	var dungeonModifierDataJSList:Array = data["dungeonModifiers"]
	for dungeonModifierDataJS in dungeonModifierDataJSList:
		var newDungeonModifierData = DungeonModifierData.new(dungeonModifierDataJS)
		dungeonModifierDict[newDungeonModifierData.id] = newDungeonModifierData

func get_dungeon_modifier_data(dungeonModifierId:String):
	return dungeonModifierDict[dungeonModifierId]

# LEVELS
func init_levels():
	var data = Utils.load_data_from_file("resource/data/levels.json")
	var levelsJSList:Array = data["levels"]
	for levelJS in levelsJSList:
		var newLevelData = LevelData.new(levelJS)
		levels.append(newLevelData)
		levelDict[newLevelData.id] = newLevelData

func get_level_data(levelId:String):
	return levelDict[levelId]
