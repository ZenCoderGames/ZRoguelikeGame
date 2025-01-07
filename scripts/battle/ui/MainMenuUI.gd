extends Node

class_name MainMenuUI

@onready var title:Label = $"%Title"
@onready var background:TextureRect = $"%Bg"
@onready var continueGameButton:Button = $"%Continue"
@onready var newGameButton:Button = $"%NewGame"
@onready var exitGameButton:Button = $"%Exit"
@onready var settingsButton:Button = $"%Settings"
@onready var backToGameButton:Button = $"%BackToGameButton"
@onready var backToStartMenuButton:Button = $"%BackToStartMenu"
@onready var musicOnButton:TextureButton = $"%MusicOnButton"
@onready var musicOffButton:TextureButton = $"%MusicOffButton"

@onready var characterSelectUI:CharacterSelectUI = $"%CharacterSelectUI"
@onready var levelSelectUI:LevelSelectUI_v2 = $"%LevelSelectUI_v2"
@onready var skillTreeUI:Node = $"%SkillTreeUI"

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
@onready var totalGoldLabel:Label = $"%TotalGoldLabel"

const BattleEndEnemyXPUIClass := preload("res://ui/battleEnd/BattleEndEnemyXPUI.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	continueGameButton.connect("button_up",Callable(self,"on_continue_game"))
	newGameButton.connect("button_up",Callable(self,"on_new_game"))
	exitGameButton.connect("button_up",Callable(self,"_on_exit_game"))
	settingsButton.connect("button_up",Callable(self,"_on_settings"))
	musicOnButton.connect("button_up",Callable(self,"_on_music_on"))
	musicOffButton.connect("button_up",Callable(self,"_on_music_off"))

	settingsButton.visible = false
	deathUI.visible = false
	victoryUI.visible = false
	backMenuUI.visible = false
	continueGameButton.visible = !PlayerDataManager.is_new_player()

	backToGameButton.connect("button_up",Callable(self,"_on_back_to_game"))
	backToStartMenuButton.connect("button_up",Callable(self,"_on_back_to_main_menu_from_battle"))
	characterSelectUI.connect("OnBackPressed",Callable(self,"_on_back_to_main_menu"))
	characterSelectUI.connect("OnSkillTreePressed",Callable(self,"_on_show_skill_tree"))
	skillTreeUI.connect("OnBackPressed",Callable(self,"_show_back_menu"))
	levelSelectUI.connect("OnBackPressed",Callable(self,"_on_back_to_character_select"))
	exitToMenuFromVictory.connect("button_up",Callable(self,"_show_back_menu"))
	exitToMenuFromDefeat.connect("button_up",Callable(self,"_show_back_menu"))

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
	_show_base_menu(true)
	characterSelectUI.visible = false
	levelSelectUI.visible = false
	continueGameButton.visible = !PlayerDataManager.is_new_player()

func _on_character_chosen(_charData):
	_show_base_menu(false)
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
	_show_base_menu(false)

	characterSelectUI.visible = true

	#if !GameGlobals.battleInstance.debugLevelId.is_empty():
	#	levelId = GameGlobals.battleInstance.debugLevelId

	characterSelectUI.init_from_data()

func _on_back_to_character_select():
	skillTreeUI.visible = false
	background.visible = true
	levelSelectUI.visible = false
	show_character_select()

func _on_settings():
	pass

func on_class_toggle(isToggleOn:bool):
	GameGlobals.battleInstance.startWithClasses = isToggleOn

func _show_defeat():
	get_node(".").visible = true
	deathUI.visible = true
	_show_base_menu(false)

	var dp:DungeonProgress = GameGlobals.dungeon.dungeonProgress
	for enemyKilledData in dp.enemyKilledList:
		var battleEndEnemyXPUI := BattleEndEnemyXPUIClass.instantiate()
		deathGridContainer.add_child(battleEndEnemyXPUI)
		battleEndEnemyXPUI.init(enemyKilledData, dp.get_enemy_count(enemyKilledData))

	deathProgressLabel.text = GameGlobals.dungeon.dungeonProgress.get_progress_description()
	PlayerDataManager.add_current_xp(GameGlobals.dungeon.dungeonProgress.get_progress())

func _show_victory():
	get_node(".").visible = true
	victoryUI.visible = true
	_show_base_menu(false)

	var dp:DungeonProgress = GameGlobals.dungeon.dungeonProgress
	for enemyKilledData in dp.enemyKilledList:
		var battleEndEnemyXPUI := BattleEndEnemyXPUIClass.instantiate()
		victoryGridContainer.add_child(battleEndEnemyXPUI)
		battleEndEnemyXPUI.init(enemyKilledData, dp.get_enemy_count(enemyKilledData))

	PlayerDataManager.add_current_xp(GameGlobals.dungeon.dungeonProgress.get_progress())
	victoryProgressLabel.text = GameGlobals.dungeon.dungeonProgress.get_progress_description()

# SKILL TREE
func _on_show_skill_tree():
	characterSelectUI.visible = false
	skillTreeUI.init_from_data("SHARED_SKILLTREE")
	skillTreeUI.visible = true
	background.visible = false

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
		
	if skillTreeUI.visible:
		UIEventManager.emit_signal("ShowSkillTree", false, "")
		_on_back_to_character_select()
		return

	if victoryUI.visible:
		_on_back_to_main_menu_from_battle()
		_on_back_to_character_select()
		return

	if deathUI.visible:
		_on_back_to_main_menu_from_battle()
		_on_back_to_character_select()
		return

	if characterSelectUI.visible:
		_on_back_to_main_menu()
		return

	if levelSelectUI.visible:
		_on_back_to_character_select()
		return

	_show_base_menu(false)
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

func _on_back_to_main_menu_from_battle():
	GameEventManager.emit_signal("OnCleanUpForDungeonRecreation", true)
	_on_back_to_main_menu()

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
	totalGoldLabel.text = str(PlayerDataManager.get_current_xp())
	
func _show_base_menu(val:bool):
	title.visible = val
	baseMenuUI.visible = val

# SETTINGS
func _on_music_on():
	musicOffButton.visible = true
	musicOnButton.visible = false
	GameGlobals.audioManager.set_as_disabled(true)

func _on_music_off():
	musicOffButton.visible = false
	musicOnButton.visible = true
	GameGlobals.audioManager.set_as_disabled(false)
