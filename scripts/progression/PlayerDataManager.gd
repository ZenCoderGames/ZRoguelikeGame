extends Node

# Currently only supports 1 profile

const PLAYER_DATA_PATH:String = "resource/data/progression/playerData.tres"

var currentPlayerData:PlayerData

signal OnPlayerDataUpdated

func _init():
	currentPlayerData = load_character_data(PLAYER_DATA_PATH)
	emit_signal("OnPlayerDataUpdated")

func _unit_test():
	#set_to_current_player_data(0)
	add_current_xp(100)
	
func add_current_xp(val:int):
	currentPlayerData.currentXP = currentPlayerData.currentXP + val
	currentPlayerData.totalXP = currentPlayerData.totalXP + val
	emit_signal("OnPlayerDataUpdated")
	save_to_file()

func save_to_file():
	save_character_data(currentPlayerData)
	
func load_character_data(path:String):
	if ResourceLoader.exists(path):
		return load(path)
	return null

func save_character_data(data):
	ResourceSaver.save(data, PLAYER_DATA_PATH)

func is_new_player():
	return currentPlayerData.totalXP == 0

func clear_player_data():
	currentPlayerData.currentXP = 0
	currentPlayerData.totalXP = 0
	emit_signal("OnPlayerDataUpdated")

func get_total_xp():
	return currentPlayerData.currentXP
