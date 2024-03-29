extends Node

# Currently only supports 1 profile

const PLAYER_DATA_PATH:String = "resource/data/progression/playerData.tres"

var currentPlayerData:PlayerData

signal OnPlayerDataUpdated

const COST_FOR_CHARACTER_UNLOCK:int = 300

func _init():
	currentPlayerData = load_character_data(PLAYER_DATA_PATH)
	emit_signal("OnPlayerDataUpdated")

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
	currentPlayerData.clear()
	emit_signal("OnPlayerDataUpdated")

# OPERATIONS
func get_current_xp():
	return currentPlayerData.currentXP

func add_current_xp(val:int):
	currentPlayerData.currentXP = currentPlayerData.currentXP + val
	currentPlayerData.totalXP = currentPlayerData.totalXP + val
	emit_signal("OnPlayerDataUpdated")
	save_to_file()

func remove_current_xp(val:int):
	currentPlayerData.currentXP = currentPlayerData.currentXP - val
	emit_signal("OnPlayerDataUpdated")
	save_to_file()

func has_character_been_unlocked(charData:CharacterData):
	if charData.id == "BERSERKER":
		return currentPlayerData.hero2Unlocked
	elif charData.id == "ASSASSIN":
		return currentPlayerData.hero3Unlocked
	elif charData.id == "GENERIC_HERO":
		return currentPlayerData.heroClasslessUnlocked

	return true

func can_unlock_character(charData:CharacterData):
	return currentPlayerData.currentXP >= charData.unlockCost

func unlock_character(charData:CharacterData):
	remove_current_xp(charData.unlockCost)
	if charData.id == "BERSERKER":
		currentPlayerData.hero2Unlocked = true
	elif charData.id == "ASSASSIN":
		currentPlayerData.hero3Unlocked = true
	elif charData.id == "GENERIC_HERO":
		currentPlayerData.heroClasslessUnlocked = true
	save_to_file()

# HELPERS
func _unit_test():
	#set_to_current_player_data(0)
	add_current_xp(100)
