## THIS IS NOW DEPRECATED AND NOT USED BY ANY SYSTEM

extends Control

class_name LevelUpUI

@onready var levelUpItemHolder:HBoxContainer = $"%LevelUpItems"
@onready var levelUpTitle:Label = $"%LevelUpTitle"

const LevelUpItemUIClass := preload("res://ui/battle/LevelUpItemUI.tscn")

var initialized:bool = false

func init_from_data(upgradeType:Upgrade.UPGRADE_TYPE):
	if initialized:
		return
		
	var hasALevelUp:bool = false

	# should optimize this to only shuffle based on upgrade type
	GameGlobals.dataManager.abilityList.shuffle()

	var abilityList:Array = []
	
	if upgradeType==Upgrade.UPGRADE_TYPE.SHARED:
		levelUpTitle.text = "GENERAL PERK"
		var allowedGeneralAbilites:int = 2
		for abilityData in GameGlobals.dataManager.abilityList:
			if abilityData.characterId=="":
				abilityList.append(abilityData)
				allowedGeneralAbilites = allowedGeneralAbilites - 1
				if allowedGeneralAbilites==0:
					break
	elif upgradeType==Upgrade.UPGRADE_TYPE.CLASS_SPECIFIC:
		levelUpTitle.text = "CLASS PERK"
		var allowedAbilites:int = 2
		for abilityData in GameGlobals.dataManager.abilityList:
			if GameGlobals.battleInstance.startWithClasses:
				if abilityData.characterId=="" or (abilityData.characterId != GameGlobals.dungeon.player.charData.id):
					continue

			if GameGlobals.dungeon.player.has_ability(abilityData):
				continue

			abilityList.append(abilityData)
			allowedAbilites = allowedAbilites - 1
			if allowedAbilites==0:
				break
	elif upgradeType==Upgrade.UPGRADE_TYPE.HYBRID:
		levelUpTitle.text = "SPECIAL PERK"
		var totalAllowedAbilities:int = 3
		# First do class specific
		var allowedAbilites:int = 2
		for abilityData in GameGlobals.dataManager.abilityList:
			if GameGlobals.battleInstance.startWithClasses:
				if abilityData.characterId=="" or (abilityData.characterId != GameGlobals.dungeon.player.charData.id):
					continue

			if GameGlobals.dungeon.player.has_ability(abilityData):
				continue

			abilityList.append(abilityData)
			allowedAbilites = allowedAbilites - 1
			totalAllowedAbilities = totalAllowedAbilities - 1
			if allowedAbilites==0:
				break
		# Then do generics
		for abilityData in GameGlobals.dataManager.abilityList:
			if (abilityData.characterId != GameGlobals.dungeon.player.charData.id):
				abilityList.append(abilityData)
				totalAllowedAbilities = totalAllowedAbilities - 1
				if totalAllowedAbilities==0:
					break

	for abilityData in abilityList:
		var levelUpItem = LevelUpItemUIClass.instantiate()
		levelUpItemHolder.add_child(levelUpItem)
		levelUpItem.init_from_data(abilityData)
		hasALevelUp = true

	initialized = true

	return hasALevelUp
