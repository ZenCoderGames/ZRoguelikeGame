extends Control

class_name LevelUpUI

@onready var levelUpItemHolder:HBoxContainer = $"%LevelUpItems"

const LevelUpItemUI := preload("res://ui/battle/LevelUpItemUI.tscn")

var initialized:bool = false

func init_from_data():
	if initialized:
		return
		
	var hasALevelUp:bool = false

	var abilityList:Array = []
	# Only allow one
	var allowedGeneralAbilites:int = 1
	for abilityData in GameGlobals.dataManager.abilityList:
		abilityList.append(abilityData)
		allowedGeneralAbilites = allowedGeneralAbilites - 1
		if allowedGeneralAbilites==0:
			break

	# Only allow up to 2 more
	var allowedAbilites:int = 2
	for abilityData in GameGlobals.dataManager.abilityList:
		if abilityData.characterId=="" and (abilityData.characterId != GameGlobals.dungeon.player.charData.id):
			continue

		if GameGlobals.dungeon.player.has_ability(abilityData):
			continue

		abilityList.append(abilityData)
		allowedAbilites = allowedAbilites - 1
		if allowedAbilites==0:
			break

	for abilityData in abilityList:
		var levelUpItem = LevelUpItemUI.instantiate()
		levelUpItemHolder.add_child(levelUpItem)
		levelUpItem.init_from_data(abilityData)
		hasALevelUp = true

	initialized = true

	return hasALevelUp
