extends Node

signal OnGameInitialized
signal OnReadyToBattle(levelData)
signal OnCharacterSelected(charData)
signal OnDungeonInitialized()
signal OnDungeonFloorCompleted()
signal OnDungeonExited(isVictory)
signal OnNewLevelLoaded()
signal OnCleanUpForDungeonRecreation(isNewDungeon:bool)
signal OnBackButtonPressed()
signal OnAudioModeChanged(val)

func ready_to_battle(levelData:LevelData):
	emit_signal("OnReadyToBattle", levelData)

func on_character_chosen(charData):
	emit_signal("OnCharacterSelected", charData)

func clean_up():
	##Utils.clean_up_all_signals(self)
	pass
