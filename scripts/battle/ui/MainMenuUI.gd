extends Node

class_name MainMenuUI

@onready var newGameButton:Button = $"%NewGameButton"
@onready var saveGameButton:Button = $"%SaveGameButton"
@onready var loadGameButton:Button = $"%LoadGameButton"
@onready var settingsButton:Button = $"%SettingsButton"

@onready var characterSelectUI:CharacterSelectUI = $"%CharacterSelectUI"
@onready var baseMenuUI:Node = $"%MenuUI"
@onready var deathUI:Node = $"%DeathUI"

# Called when the node enters the scene tree for the first time.
func _ready():
	newGameButton.connect("button_up",Callable(self,"on_new_game"))
	saveGameButton.connect("button_up",Callable(self,"on_save_game"))
	loadGameButton.connect("button_up",Callable(self,"on_load_game"))
	settingsButton.connect("button_up",Callable(self,"on_settings"))
	deathUI.visible = false
	
	GameEventManager.connect("OnDungeonInitialized",Callable(self,"_on_dungeon_init"))
	GameEventManager.connect("OnCleanUpForDungeonRecreation",Callable(self,"_on_cleanup_for_dungeon"))
	GameEventManager.connect("OnNewLevelLoaded",Callable(self,"_on_dungeon_init"))
	GameEventManager.connect("OnCharacterSelected",Callable(self,"_on_character_chosen"))

func _on_character_chosen(_charData):
	baseMenuUI.visible = false
	
func _on_dungeon_init():
	_clean_up()
	_shared_init()

func _shared_init():
	GameGlobals.dungeon.player.connect("OnDeath",Callable(self,"_on_game_over"))

func show_menu():
	baseMenuUI.visible = true
	characterSelectUI.visible = false

func on_new_game():
	UIEventManager.emit_signal("OnMainMenuButton")
	_clean_up()
	baseMenuUI.visible = false

	if GameGlobals.battleInstance.startWithClasses:
		characterSelectUI.visible = true
		characterSelectUI.init_from_data()
	else:
		GameEventManager.on_character_chosen(GameGlobals.dataManager.get_character_data("GENERIC_HERO"))
		GameEventManager.ready_to_battle()
	
func on_save_game():
	pass
	
func on_load_game():
	pass
	
func on_settings():
	pass

func _on_game_over():
	await GameGlobals.battleInstance.get_tree().create_timer(Constants.SHOW_DEATH_UI_TIME).timeout
	
	get_node(".").visible = true
	deathUI.visible = true
	baseMenuUI.visible = false

	await GameGlobals.battleInstance.get_tree().create_timer(Constants.DEATH_TO_MENU_TIME).timeout

	baseMenuUI.visible = true
	characterSelectUI.visible = false

func _clean_up():
	deathUI.visible = false
	characterSelectUI.visible = false

func _on_cleanup_for_dungeon(fullRefreshDungeon:bool=true):
	if fullRefreshDungeon:
		var player = GameGlobals.dungeon.player
		if player!=null and !player.is_queued_for_deletion():
			player.disconnect("OnDeath",Callable(self,"_on_game_over"))

