extends Node

#const PLAYER_DATA_PATH:String = "resource/data/progression/playerData.json"
const PLAYER_DATA_PATH:String = "resource/data/progression/playerData.tres"

var currentPlayerData:PlayerData

func _init():
	currentPlayerData = load_character_data()

func _unit_test():
	#set_to_current_player_data(0)
	add_current_xp(100)
	add_current_level(2)
	
func add_current_xp(val:int):
	currentPlayerData.currentXP = currentPlayerData.currentXP + val
	currentPlayerData.totalXP = currentPlayerData.totalXP + val

func add_current_level(val:int):
	currentPlayerData.currentLevel = currentPlayerData.currentLevel + val

func save_to_file():
	save_character_data(currentPlayerData)
	
func load_character_data():
	if ResourceLoader.exists(PLAYER_DATA_PATH):
		return load(PLAYER_DATA_PATH)
	return null

func save_character_data(data):
	ResourceSaver.save(data, PLAYER_DATA_PATH)
