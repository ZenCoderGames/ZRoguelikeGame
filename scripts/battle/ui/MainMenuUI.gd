extends Node

class_name MainMenuUI

@onready var tutorialButton:Button = $"%Tutorial"
@onready var continueGameButton:Button = $"%Continue"
@onready var newGameButton:Button = $"%NewGame"
@onready var exitGameButton:Button = $"%Exit"
@onready var settingsButton:Button = $"%Settings"
@onready var backToGameButton:Button = $"%BackToGameButton"
@onready var backToStartMenuButton:Button = $"%BackToStartMenu"

@onready var characterSelectUI:CharacterSelectUI = $"%CharacterSelectUI"
@onready var levelSelectUI:LevelSelectUI = $"%LevelSelectUI"

@onready var baseMenuUI:Node = $"%MenuUI"
@onready var deathUI:Node = $"%DeathUI"
@onready var deathGridContainer:GridContainer = $"%DeathGridContainer"
@onready var victoryUI:Node = $"%VictoryUI"
@onready var victoryGridContainer:GridContainer = $"%VictoryGridContainer"
@onready var backMenuUI:Node = $"%BackMenuUI"
@onready var exitToMenuFromVictory:Button = $"%VictoryBackToMenu"
@onready var exitToMenuFromDefeat:Button = $"%DeathBackToMenu"

@onready var victoryProgressLabel:Label = $"%VictoryProgressLabel"
@onready var deathProgressLabel:Label = $"%DeathProgressLabel"
@onready var totalSoulsLabel:Label = $"%TotalSoulsLabel"

const BattleEndEnemyXPUIClass := preload("res://ui/battleEnd/BattleEndEnemyXPUI.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	tutorialButton.connect("button_up",Callable(self,"on_tutorial"))
	continueGameButton.connect("button_up",Callable(self,"on_continue_game"))
	newGameButton.connect("button_up",Callable(self,"on_new_game"))
	exitGameButton.connect("button_up",Callable(self,"_on_exit_game"))
	settingsButton.connect("button_up",Callable(self,"on_settings"))

	settingsButton.visible = false
	deathUI.visible = false
	victoryUI.visible = false
	backMenuUI.visible = false
	continueGameButton.visible = !PlayerDataManager.is_new_player()

	backToGameButton.connect("button_up",Callable(self,"_on_back_to_game"))
	backToStartMenuButton.connect("button_up",Callable(self,"_on_back_to_main_menu"))
	characterSelectUI.connect("OnBackPressed",Callable(self,"_on_back_to_main_menu"))
	levelSelectUI.connect("OnBackPressed",Callable(self,"_on_back_to_character_select"))
	exitToMenuFromVictory.connect("button_up",Callable(self,"_on_back_to_main_menu"))
	exitToMenuFromDefeat.connect("button_up",Callable(self,"_on_back_to_main_menu"))

	GameEventManager.connect("OnBackButtonPressed",Callable(self,"_show_back_menu"))
	GameEventManager.connect("OnDungeonInitialized",Callable(self,"_on_dungeon_init"))
	GameEventManager.connect("OnDungeonExited",Callable(self,"_on_dungeon_completed"))
	GameEventManager.connect("OnNewLevelLoaded",Callable(self,"_on_dungeon_init"))
	GameEventManager.connect("OnCharacterSelected",Callable(self,"_on_character_chosen"))

	PlayerDataManager.connect("OnPlayerDataUpdated",Callable(self,"_on_player_data_updated"))
	_on_player_data_updated()

	show_menu()
	
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
	levelSelectUI.visible = false

func _on_character_chosen(_charData):
	baseMenuUI.visible = false
	characterSelectUI.visible = false
	levelSelectUI.visible = true
	levelSelectUI.init_from_data(_charData)
	#GameEventManager.ready_to_battle(myLevelData)

func on_tutorial():
	show_character_select()

func on_continue_game():
	show_character_select()
	
func on_new_game():
	PlayerDataManager.clear_player_data()
	show_character_select()

# CHARACTER SELECT
func show_character_select():
	UIEventManager.emit_signal("OnMainMenuButton")
	_clean_up()
	baseMenuUI.visible = false

	characterSelectUI.visible = true

	#if !GameGlobals.battleInstance.debugLevelId.is_empty():
	#	levelId = GameGlobals.battleInstance.debugLevelId

	characterSelectUI.init_from_data()

func _on_back_to_character_select():
	characterSelectUI.visible = true
	levelSelectUI.visible = false

func on_settings():
	pass

func on_class_toggle(isToggleOn:bool):
	GameGlobals.battleInstance.startWithClasses = isToggleOn

func _show_defeat():
	get_node(".").visible = true
	deathUI.visible = true
	baseMenuUI.visible = false

	var dp:DungeonProgress = GameGlobals.dungeon.dungeonProgress
	for enemyKilledData in dp.enemyKilledList:
		var battleEndEnemyXPUI := BattleEndEnemyXPUIClass.instantiate()
		deathGridContainer.add_child(battleEndEnemyXPUI)
		battleEndEnemyXPUI.init(enemyKilledData)

	deathProgressLabel.text = GameGlobals.dungeon.dungeonProgress.get_progress_description()
	PlayerDataManager.add_current_xp(GameGlobals.dungeon.dungeonProgress.get_progress())

func _show_victory():
	get_node(".").visible = true
	victoryUI.visible = true
	baseMenuUI.visible = false

	var dp:DungeonProgress = GameGlobals.dungeon.dungeonProgress
	for enemyKilledData in dp.enemyKilledList:
		var battleEndEnemyXPUI := BattleEndEnemyXPUIClass.instantiate()
		victoryGridContainer.add_child(battleEndEnemyXPUI)
		battleEndEnemyXPUI.init(enemyKilledData)

	victoryProgressLabel.text = GameGlobals.dungeon.dungeonProgress.get_progress_description()
	PlayerDataManager.add_current_xp(GameGlobals.dungeon.dungeonProgress.get_progress())

func _clean_up():
	victoryUI.visible = false
	deathUI.visible = false
	characterSelectUI.visible = false
	levelSelectUI.visible = false

# BACK MENU
func _show_back_menu():
	if backMenuUI.visible:
		_on_back_to_game()
		return

	if victoryUI.visible:
		_on_back_to_main_menu()
		return

	if deathUI.visible:
		_on_back_to_main_menu()
		return

	if characterSelectUI.visible:
		_on_back_to_main_menu()
		return

	if levelSelectUI.visible:
		_on_back_to_character_select()
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
	deathUI.visible = false
	victoryUI.visible = false
	show_menu()

func _on_exit_game():
	get_tree().quit()

func _clear_end_screen():
	var victoryGridChildren:Array = victoryGridContainer.get_children()
	for gridItem in victoryGridChildren:
		victoryGridContainer.remove_child(gridItem)
		gridItem.queue_free()

	var deathGridChildren:Array = deathGridContainer.get_children()
	for gridItem in deathGridChildren:
		deathGridContainer.remove_child(gridItem)
		gridItem.queue_free()

func _on_player_data_updated():
	totalSoulsLabel.text = str("Total Souls: ", PlayerDataManager.get_total_xp())
