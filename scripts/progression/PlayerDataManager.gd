extends Node

# Currently only supports 1 profile

#const PLAYER_DATA_PATH:String = "resource/data/progression/playerData.tres"
const PLAYER_DATA_PATH:String = "user://playerData.tres"

var currentPlayerData:PlayerData

signal OnPlayerDataUpdated

const COST_FOR_CHARACTER_UNLOCK:int = 300

func _init():
	currentPlayerData = load_character_data(PLAYER_DATA_PATH)
	currentPlayerData.init()
	emit_signal("OnPlayerDataUpdated")
	GameEventManager.connect("OnDungeonExited",Callable(self,"_on_dungeon_exited"))

func save_to_file():
	save_character_data(currentPlayerData)
	
func load_character_data(path:String):
	if ResourceLoader.exists(path):
		return ResourceLoader.load(path)
	
	var newPlayerData = PlayerData.new()
	newPlayerData.init_as_new()
	save_character_data(newPlayerData)
	return newPlayerData

func save_character_data(data):
	ResourceSaver.save(data, PLAYER_DATA_PATH)

func is_new_player():
	return currentPlayerData.totalXP == 0

func clear_player_data():
	currentPlayerData.clear()
	emit_signal("OnPlayerDataUpdated")
	save_to_file()

# XP
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
	
func add_hero_xp(charId:String, val:int):
	currentPlayerData.add_hero_xp(charId, val)
	emit_signal("OnPlayerDataUpdated")
	save_to_file()

# CHARACTERS
func has_character_been_unlocked(charData:CharacterData):
	return currentPlayerData.heroDataDict[charData.id].unlocked

func can_unlock_character(charData:CharacterData):
	return currentPlayerData.currentXP >= charData.unlockCost

func unlock_character(charData:CharacterData):
	remove_current_xp(charData.unlockCost)
	currentPlayerData.unlockHero(charData.id) 
	save_to_file()

# SKILL TREE
func has_skill_been_unlocked(skillDataId:String):
	return currentPlayerData.isSkillUnlocked(skillDataId)

func can_unlock_skill(skillData:SkillData):
	return currentPlayerData.currentXP >= skillData.unlockCost

func unlock_skill(skillData:SkillData):
	remove_current_xp(skillData.unlockCost)
	currentPlayerData.unlockSkill(skillData.id) 
	save_to_file()

func get_unlocked_skills()->Array[String]:
	return currentPlayerData.get_unlocked_skills()

func is_skill_enabled(charData:CharacterData, skillData:SkillData):
	return currentPlayerData.is_skill_enabled(charData, skillData.id)

func can_enable_skill(charData:CharacterData, skillData:SkillData):
	return currentPlayerData.can_enable_skill(charData, skillData.id)

func get_remaining_skill_threshold(charData:CharacterData):
	return currentPlayerData.get_remaining_skill_threshold(charData)

func enable_skill(charData:CharacterData, skillData:SkillData):
	currentPlayerData.enable_skill(charData, skillData.id) 
	save_to_file()
	
func disable_skill(charData:CharacterData, skillData:SkillData):
	currentPlayerData.disable_skill(charData, skillData.id) 
	save_to_file()

# LEVELS
func is_level_completed(charData:CharacterData, levelId:String):
	return currentPlayerData.heroDataDict[charData.id].levelsCompleted.has(levelId)

func level_complete(charData:CharacterData, levelId:String):
	currentPlayerData.heroDataDict[charData.id].level_completed(levelId)

func _on_dungeon_exited(isVictory:bool):
	if isVictory:
		level_complete(GameGlobals.dataManager.playerData, GameGlobals.battleInstance.currentLevelData.id)

# HELPERS
func _unit_test():
	#set_to_current_player_data(0)
	add_current_xp(100)
