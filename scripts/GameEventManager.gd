extends Node

signal OnReadyToBattle
signal OnCharacterSelected(charData)
signal OnDungeonInitialized()
signal OnDungeonRecreated()
signal OnGameOver()
signal OnMainMenuOn()
signal OnMainMenuOff()

func ready_to_battle():
	emit_signal("OnReadyToBattle")

func on_character_chosen(charData):
	emit_signal("OnCharacterSelected", charData)
