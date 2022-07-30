# Tracks all the data in the game
class_name DungeonDataManager

var actionDataMap = {}
var itemDataMap = {}

var characterDataDict = {}
var playerData:CharacterData
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
			
func get_action(id):
	return actionDataMap[id]

func init_items():
	pass

func init_characters():
	var data = Utils.load_data_from_file("resource/characters.json")
	var charDataJSList:Array = data["characters"]
	for charDataJS in charDataJSList:
		var newCharData = CharacterData.new(charDataJS)
		if newCharData.id == "PLAYER":
			playerData = newCharData
		else:
			if !newCharData.disable:
				enemyDataList.append(newCharData)
		characterDataDict[newCharData.id] = newCharData

func get_random_enemy_data():
	return enemyDataList[randi() % enemyDataList.size()]
