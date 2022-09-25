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

func _init():
	init_complex_stats()
	init_status_effects()
	init_passives()
	init_spells()
	init_items()
	init_characters()

func on_character_chosen(charData):
	playerData = charData

func init_status_effects():
	var data = Utils.load_data_from_file("resource/statusEffects.json")
	var statusEffectDataJSList:Array = data["statusEffects"]
	for statusEffectDataJS in statusEffectDataJSList:
		var newStatusEffectData = StatusEffectData.new(statusEffectDataJS)
		statusEffectDataMap[newStatusEffectData.id] = newStatusEffectData

func get_status_effect_data(id):
	return statusEffectDataMap[id]

func init_passives():
	var data = Utils.load_data_from_file("resource/passives.json")
	var passiveDataJSList:Array = data["passives"]
	for passiveDataJS in passiveDataJSList:
		var newPassiveData = PassiveData.new(passiveDataJS)
		passiveDataMap[newPassiveData.id] = newPassiveData

func get_passive_data(id):
	return passiveDataMap[id]

func init_items():
	var data = Utils.load_data_from_file("resource/items.json")
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
	var data = Utils.load_data_from_file("resource/characters.json")
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
		
	playerData = characterDataDict["KNIGHT"]

func get_random_enemy_data():
	return enemyDataList[randi() % enemyDataList.size()]

func get_enemy_data(enemyId):
	return characterDataDict[enemyId]

func get_random_item_data():
	return itemDataList[randi() % itemDataList.size()]

func init_spells():
	var data = Utils.load_data_from_file("resource/spells.json")
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
	var data = Utils.load_data_from_file("resource/complexStats.json")
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
