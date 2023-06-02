extends Node

func _ready():
	UIEventManager.connect("OnMainMenuButton",Callable(self,"_on_main_menu_button"))
	UIEventManager.connect("OnCharacterSelectButton",Callable(self,"_on_character_select_button"))
	GameEventManager.connect("OnDungeonInitialized",Callable(self,"_on_dungeon_initialized"))
	CombatEventManager.connect("OnAnyAttack",Callable(self,"_on_any_character_attack"))
	CombatEventManager.connect("OnAnyCharacterDeath",Callable(self,"_on_any_character_death"))
	CombatEventManager.connect("OnPlayerSpecialAbilityReady",Callable(self,"_on_player_special_ready"))
	CombatEventManager.connect("OnPlayerSpecialAbilityPressed",Callable(self,"_on_player_special_activated"))

func _on_main_menu_button():
	GameGlobals.audioManager.play("UI_BUTTON_MAIN_MENU")

func _on_character_select_button():
	GameGlobals.audioManager.play("UI_BUTTON_CHARACTER_SELECT")

func _on_dungeon_initialized():
	GameGlobals.dungeon.player.connect("OnCharacterMoveToCell", Callable(self,"_on_player_move"))
	GameGlobals.dungeon.player.connect("OnCharacterItemPicked", Callable(self,"_on_player_item_picked"))

func _on_player_move():
	GameGlobals.audioManager.play("PLAYER_MOVE")

func _on_player_item_picked():
	GameGlobals.audioManager.play("ITEM_PICKUP")

func _on_any_character_attack(entity):
	if entity.team ==Constants.TEAM.ENEMY:
		GameGlobals.audioManager.play("ENEMY_ATTACK")
	else:
		GameGlobals.audioManager.play("PLAYER_ATTACK")

func _on_any_character_death(character:Character):
	if character.team ==Constants.TEAM.ENEMY:
		GameGlobals.audioManager.play("ENEMY_DEATH")
	else:
		GameGlobals.audioManager.play("PLAYER_DEATH")

func _on_player_special_ready():
	GameGlobals.audioManager.play("PLAYER_SPECIAL_READY")

func _on_player_special_activated():
	GameGlobals.audioManager.play("PLAYER_SPECIAL_ON_ACTIVATE")
