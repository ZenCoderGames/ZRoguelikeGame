extends Node

class_name MainMenuUI

@onready var tutorialButton:Button = $"%Tutorial"
@onready var easyGameButton:Button = $"%Easy"
@onready var balancedGameButton:Button = $"%Balanced"
@onready var hardGameButton:Button = $"%Hard"
@onready var settingsButton:Button = $"%SettingsButton"
@onready var classToggle:CheckButton = $"%ClassToggle"
@onready var backToGameButton:Button = $"%BackToGameButton"
@onready var backToStartMenuButton:Button = $"%BackToStartMenu"
@onready var exitGameButton:Button = $"%ExitGameButton"

@onready var characterSelectUI:CharacterSelectUI = $"%CharacterSelectUI"
@onready var baseMenuUI:Node = $"%MenuUI"
@onready var deathUI:Node = $"%DeathUI"
@onready var victoryUI:Node = $"%VictoryUI"
@onready var backMenuUI:Node = $"%BackMenuUI"
@onready var exitToMenuFromVictory:Button = $"%VictoryBackToMenu"

# Called when the node enters the scene tree for the first time.
func _ready():
	tutorialButton.connect("button_up",Callable(self,"on_tutorial"))
	easyGameButton.connect("button_up",Callable(self,"on_easy_game"))
	balancedGameButton.connect("button_up",Callable(self,"on_balanced_game"))
	hardGameButton.connect("button_up",Callable(self,"on_hard_game"))
	settingsButton.connect("button_up",Callable(self,"on_settings"))

	classToggle.visible = false
	deathUI.visible = false
	victoryUI.visible = false
	backMenuUI.visible = false

	backToGameButton.connect("button_up",Callable(self,"_on_back_to_game"))
	backToStartMenuButton.connect("button_up",Callable(self,"_on_back_to_main_menu"))
	characterSelectUI.connect("OnBackPressed",Callable(self,"_on_back_to_main_menu"))
	exitGameButton.connect("button_up",Callable(self,"_on_exit_game"))
	exitToMenuFromVictory.connect("button_up",Callable(self,"_on_back_to_main_menu"))

	GameEventManager.connect("OnBackButtonPressed",Callable(self,"_show_back_menu"))
	GameEventManager.connect("OnDungeonInitialized",Callable(self,"_on_dungeon_init"))
	GameEventManager.connect("OnDungeonExited",Callable(self,"_on_dungeon_completed"))
	GameEventManager.connect("OnNewLevelLoaded",Callable(self,"_on_dungeon_init"))
	GameEventManager.connect("OnCharacterSelected",Callable(self,"_on_character_chosen"))

func _on_character_chosen(_charData):
	baseMenuUI.visible = false
	
func _on_dungeon_init():
	_clean_up()
	_shared_init()

func _shared_init():
	pass

func _on_dungeon_completed(isVictory:bool):
	if isVictory:
		_show_victory()
	else:
		_show_defeat()

func show_menu():
	get_node(".").visible = true
	baseMenuUI.visible = true
	characterSelectUI.visible = false

func on_tutorial():
	start_battle("LEVEL_TUTORIAL")

func on_easy_game():
	start_battle("LEVEL_EASY")
	
func on_balanced_game():
	start_battle("LEVEL_BALANCED")
	
func on_hard_game():
	start_battle("LEVEL_HARD")

func start_battle(levelId:String):
	UIEventManager.emit_signal("OnMainMenuButton")
	_clean_up()
	baseMenuUI.visible = false
	
	# Always have class selection
	characterSelectUI.visible = true

	if !GameGlobals.battleInstance.debugLevelId.is_empty():
		levelId = GameGlobals.battleInstance.debugLevelId

	characterSelectUI.init_from_data(levelId)

func on_settings():
	pass

func on_class_toggle(isToggleOn:bool):
	GameGlobals.battleInstance.startWithClasses = isToggleOn

func _show_defeat():
	await GameGlobals.battleInstance.get_tree().create_timer(Constants.SHOW_DEATH_UI_TIME).timeout
	
	get_node(".").visible = true
	deathUI.visible = true
	baseMenuUI.visible = false

	await GameGlobals.battleInstance.get_tree().create_timer(Constants.DEATH_TO_MENU_TIME).timeout

	baseMenuUI.visible = true
	characterSelectUI.visible = false

func _show_victory():
	get_node(".").visible = true
	victoryUI.visible = true
	baseMenuUI.visible = false

func _clean_up():
	victoryUI.visible = false
	deathUI.visible = false
	characterSelectUI.visible = false

# BACK MENU
func _show_back_menu():
	if backMenuUI.visible:
		_on_back_to_game()
		return

	if victoryUI.visible:
		_on_back_to_main_menu()
		return

	if characterSelectUI.visible:
		_on_back_to_main_menu()
		return

	baseMenuUI.visible = false
	if GameGlobals.dungeon==null or !GameGlobals.dungeon.inBackableMenu:
		get_node(".").visible = true
		backMenuUI.visible = true
	else:
		_on_back_to_game()

func _on_back_to_game():
	get_node(".").visible = false
	backMenuUI.visible = false
	if GameGlobals.dungeon==null or !GameGlobals.dungeon.isInitialized:
		show_menu()

func _on_back_to_main_menu():
	UIEventManager.emit_signal("OnMainMenuButton")
	backMenuUI.visible = false
	victoryUI.visible = false
	show_menu()

func _on_exit_game():
	get_tree().quit()
