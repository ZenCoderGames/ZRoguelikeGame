extends Node

class_name AudioHandler

func _ready():
	GameEventManager.connect("OnGameInitialized",Callable(self,"_play_menu_music"))
	GameEventManager.connect("OnDungeonInitialized",Callable(self,"_on_dungeon_initialized"))
	GameEventManager.connect("OnCharacterSelected",Callable(self,"_on_char_selected"))
	GameEventManager.connect("OnDungeonExited",Callable(self,"_on_dungeon_exited"))
	GameEventManager.connect("OnAudioModeChanged",Callable(self,"_on_audio_mode_changed"))
	UIEventManager.connect("OnMainMenuButton",Callable(self,"_on_main_menu_button"))
	UIEventManager.connect("OnCharacterSelectButton",Callable(self,"_on_character_select_button"))
	UIEventManager.connect("OnGenericUIEvent",Callable(self,"_on_generic_ui_event"))
	UIEventManager.connect("OnMainMenuOn",Callable(self,"_on_menu_on"))
	UIEventManager.connect("OnMainMenuOff",Callable(self,"_on_menu_off"))
	CombatEventManager.connect("OnAnyAttack",Callable(self,"_on_any_character_attack"))
	CombatEventManager.connect("OnAnyCharacterDeath",Callable(self,"_on_any_character_death"))
	CombatEventManager.connect("OnConsumeItem",Callable(self,"_on_consume_item"))
	CombatEventManager.connect("OnPlayerSpecialAbilityReady",Callable(self,"_on_player_special_ready"))
	CombatEventManager.connect("OnPlayerSpecialAbilityActivated",Callable(self,"_on_player_special_activated"))
	CombatEventManager.connect("OnPlayerSpecialAbilityCompleted",Callable(self,"_on_player_special_completed"))
	AudioEventManager.connect("OnGenericPickup",Callable(self,"_on_generic_pickup"))

# MUSIC
func _on_menu_on():
	GameGlobals.audioManager.dim_music_volume("MUSIC_TITLE_SCREEN", false)

func _on_menu_off():
	GameGlobals.audioManager.dim_music_volume("MUSIC_TITLE_SCREEN", true)

func _on_char_selected(_selectedChar):
	pass
	#_on_menu_off()

func _on_dungeon_exited(isVictory:bool):
	_on_menu_on()

# SFX
func _on_main_menu_button():
	GameGlobals.audioManager.play_sfx("UI_BUTTON_MAIN_MENU")

func _on_character_select_button():
	GameGlobals.audioManager.play_sfx("UI_BUTTON_CHARACTER_SELECT")

func _on_generic_ui_event():
	GameGlobals.audioManager.play_sfx("UI_BUTTON_CHARACTER_SELECT")

func _on_dungeon_initialized():
	GameGlobals.dungeon.player.connect("OnCharacterMoveToCell", Callable(self,"_on_player_move"))
	GameGlobals.dungeon.player.connect("OnCharacterFailedToMove", Callable(self,"_on_player_failed_to_move"))
	GameGlobals.dungeon.player.connect("OnCharacterItemPicked", Callable(self,"_on_player_item_picked"))
	GameGlobals.dungeon.player.connect("OnPlayerReachedEnd",Callable(self,"_play_menu_music"))

func _on_player_move():
	GameGlobals.audioManager.play_sfx("PLAYER_MOVE")

func _on_player_failed_to_move(_x, _y):
	GameGlobals.audioManager.play_sfx("PLAYER_MOVE")

func _on_player_item_picked():
	GameGlobals.audioManager.play_sfx("ITEM_PICKUP")

func _on_generic_pickup():
	GameGlobals.audioManager.play_sfx("ITEM_PICKUP")

func _on_any_character_attack(entity):
	if entity.team ==Constants.TEAM.ENEMY:
		GameGlobals.audioManager.play_sfx("ENEMY_ATTACK")
	else:
		GameGlobals.audioManager.play_sfx("PLAYER_ATTACK")

func _on_any_character_death(character:Character):
	if character.team ==Constants.TEAM.ENEMY:
		GameGlobals.audioManager.play_sfx("ENEMY_DEATH")
	else:
		GameGlobals.audioManager.play_sfx("PLAYER_DEATH")

func _on_player_special_ready(_special:Special):
	GameGlobals.audioManager.play_sfx("PLAYER_SPECIAL_READY")

func _on_player_special_activated(_special:Special):
	GameGlobals.audioManager.play_sfx("PLAYER_SPECIAL_ON_ACTIVATE")

func _on_player_special_completed(_special:Special):
	GameGlobals.audioManager.play_sfx("PLAYER_SPECIAL_READY")

func _on_consume_item(itemData:ItemData):
	if !itemData.consumeAudioId.is_empty():
		GameGlobals.audioManager.play_sfx(itemData.consumeAudioId)
		
func _on_audio_mode_changed(val:bool):
	if val:
		GameGlobals.audioManager.play_music("MUSIC_TITLE_SCREEN")
	else:
		GameGlobals.audioManager.stop_music("MUSIC_TITLE_SCREEN")
