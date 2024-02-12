extends Node

signal OnGameInitialized
signal OnReadyToBattle(dungeonPath)
signal OnCharacterSelected(charData)
signal OnDungeonInitialized()
signal OnGameOver()
signal OnNewLevelLoaded()
signal OnCleanUpForDungeonRecreation(isNewDungeon:bool)
signal OnBackButtonPressed()

func ready_to_battle(dungeonPath:String):
	emit_signal("OnReadyToBattle", dungeonPath)

func on_character_chosen(charData):
	emit_signal("OnCharacterSelected", charData)

func clean_up():
	##Utils.clean_up_all_signals(self)
	pass
