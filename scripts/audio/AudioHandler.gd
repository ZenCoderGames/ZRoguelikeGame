extends Node

class_name AudioHandler

func _ready():
	GameEventManager.connect("OnGameInitialized",Callable(self,"_play_menu_music"))
	GameEventManager.connect("OnDungeonInitialized",Callable(self,"_on_dungeon_initialized"))
	GameEventManager.connect("OnCharacterSelected",Callable(self,"_on_char_selected"))
	GameEventManager.connect("OnGameOver",Callable(self,"_play_menu_music"))
	UIEventManager.connect("OnMainMenuButton",Callable(self,"_on_main_menu_button"))
	UIEventManager.connect("OnCharacterSelectButton",Callable(self,"_on_character_select_button"))
	UIEventManager.connect("OnGenericUIEvent",Callable(self,"_on_generic_ui_event"))
	UIEventManager.connect("OnMainMenuOn",Callable(self,"_play_menu_music"))
	UIEventManager.connect("OnMainMenuOff",Callable(self,"_stop_menu_music"))
	CombatEventManager.connect("OnAnyAttack",Callable(self,"_on_any_character_attack"))
	CombatEventManager.connect("OnAnyCharacterDeath",Callable(self,"_on_any_character_death"))
	CombatEventManager.connect("OnConsumeItem",Callable(self,"_on_consume_item"))
	CombatEventManager.connect("OnPlayerSpecialAbilityReady",Callable(self,"_on_player_special_ready"))
	CombatEventManager.connect("OnPlayerSpecialAbilityActivated",Callable(self,"_on_player_special_activated"))

# MUSIC
func _play_menu_music():
	GameGlobals.audioManager.play_music("MUSIC_TITLE_SCREEN")

func _stop_menu_music():
	GameGlobals.audioManager.stop_music("MUSIC_TITLE_SCREEN")

func _on_char_selected(_selectedChar):
	GameGlobals.audioManager.stop_music("MUSIC_TITLE_SCREEN")

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

func _on_player_special_ready(special:Special):
	GameGlobals.audioManager.play_sfx("PLAYER_SPECIAL_READY")

func _on_player_special_activated(special:Special):
	GameGlobals.audioManager.play_sfx("PLAYER_SPECIAL_ON_ACTIVATE")

func _on_consume_item(itemData:ItemData):
	if !itemData.consumeAudioId.is_empty():
		GameGlobals.audioManager.play_sfx(itemData.consumeAudioId)
