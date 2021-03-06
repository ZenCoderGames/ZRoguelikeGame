# Tracks all the data in the game
class_name DungeonDataManager

var actionDataMap = {}
var itemDataMap = {}
var itemDataList = []

var characterDataDict = {}
var playerData:CharacterData
var heroDataList = []
var enemyDataList = []

func _init():
	init_actions()
	init_items()
	init_characters()

func init_actions():
	var data = Utils.load_data_from_file("resource/actions.json")
	var actionDataJSList:Array = data["actions"]
	for actionDataJS in actionDataJSList:
		var newActionData = ActionDataTypes.create(actionDataJS)
		actionDataMap[newActionData.id] = newActionData
			
func get_action_data(id):
	return actionDataMap[id]

func init_items():
	var data = Utils.load_data_from_file("resource/items.json")
	var itemDataJSList:Array = data["items"]
	for itemDataJS in itemDataJSList:
		var newItemData = ItemData.new(itemDataJS, actionDataMap)
		itemDataMap[newItemData.id] = newItemData
		itemDataList.append(newItemData)

func get_item_data(id):
	return itemDataMap[id]

func init_characters():
	var data = Utils.load_data_from_file("resource/characters.json")
	var heroDataJSList:Array = data["characters"]["heroes"]
	for heroDataJS in heroDataJSList:
		var newCharData = CharacterData.new(heroDataJS, actionDataMap)
		heroDataList.append(newCharData)
		characterDataDict[newCharData.id] = newCharData
	var enemyDataJSList:Array = data["characters"]["enemies"]
	for enemyDataJS in enemyDataJSList:
		var newCharData = CharacterData.new(enemyDataJS, actionDataMap)
		if !newCharData.disable:
			enemyDataList.append(newCharData)
		characterDataDict[newCharData.id] = newCharData
		
	playerData = heroDataList[0]

func get_random_enemy_data():
	return enemyDataList[randi() % enemyDataList.size()]

func get_random_item_data():
	return itemDataList[4]
	#return itemDataList[randi() % itemDataList.size()]
