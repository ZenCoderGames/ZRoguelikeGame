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
@onready var skillTreeUI:Node = $"%SkillTreeUI_v2"

@onready var baseMenuUI:Node = $"%MenuUI"
@onready var deathUI:DeathUI = $"%DeathUI"
@onready var victoryUI:VictoryUI = $"%VictoryUI"
@onready var backMenuUI:Node = $"%BackMenuUI"

@onready var totalGoldLabel:Label = $"%TotalGoldLabel"

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
	victoryUI.connect("OnBackPressed",Callable(self,"_show_back_menu"))
	deathUI.connect("OnBackPressed",Callable(self,"_show_back_menu"))

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
	_setup_keyboard_focus()

func _on_character_chosen(_charData):
	_show_base_menu(false)
	characterSelectUI.visible = false
	levelSelectUI.visible = true
	levelSelectUI.init_from_data(_charData)
	#GameEventManager.ready_to_battle(myLevelData)
	GameGlobals.change_state(GameGlobals.STATES.LEVEL_SELECT)

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
	GameGlobals.change_state(GameGlobals.STATES.CHARACTER_SELECT)

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
	GameGlobals.change_substate(GameGlobals.SUB_STATES.DEFEAT)
	get_node(".").visible = true
	deathUI.init_data()
	deathUI.visible = true
	_show_base_menu(false)

func _show_victory():
	GameGlobals.change_substate(GameGlobals.SUB_STATES.VICTORY)
	get_node(".").visible = true
	victoryUI.init_data()
	victoryUI.visible = true
	_show_base_menu(false)

# SKILL TREE
func _on_show_skill_tree():
	characterSelectUI.visible = false
	skillTreeUI.init_from_data("SHARED_SKILLTREE")
	skillTreeUI.visible = true
	background.visible = false
	GameGlobals.change_state(GameGlobals.STATES.SKILL_TREE)

func _clean_up():
	victoryUI.visible = false
	deathUI.visible = false
	characterSelectUI.visible = false
	levelSelectUI.visible = false

# BACK MENU
func _show_back_menu():
	if GameGlobals.is_in_state(GameGlobals.STATES.BATTLE):
		if GameGlobals.is_in_substate(GameGlobals.SUB_STATES.VICTORY) or GameGlobals.is_in_substate(GameGlobals.SUB_STATES.DEFEAT) :
			_on_back_to_main_menu_from_battle()
			_on_back_to_character_select()
		elif GameGlobals.is_in_substate(GameGlobals.SUB_STATES.IN_BATTLE_BACK_MENU):
			_on_back_to_game()
		else:
			_show_base_menu(false)
			if GameGlobals.dungeon==null or !GameGlobals.dungeon.inBackableMenu:
				_show_battle_back_menu()
			else:
				_on_back_to_game()
	elif GameGlobals.is_in_state(GameGlobals.STATES.SKILL_TREE):
		UIEventManager.emit_signal("ShowSkillTree", false, "")
		_on_back_to_character_select()
	elif GameGlobals.is_in_state(GameGlobals.STATES.CHARACTER_SELECT):
		_on_back_to_main_menu()
	elif GameGlobals.is_in_state(GameGlobals.STATES.LEVEL_SELECT):
		_on_back_to_character_select()

func _show_battle_back_menu():
	get_node(".").visible = true
	backMenuUI.visible = true
	GameGlobals.change_substate(GameGlobals.SUB_STATES.IN_BATTLE_BACK_MENU)
	_setup_keyboard_focus()

func _on_back_to_game():
	GameGlobals.change_substate(GameGlobals.SUB_STATES.NONE)
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
	victoryUI.clean_up()
	deathUI.clean_up()

func _on_player_data_updated():
	totalGoldLabel.text = str(PlayerDataManager.get_current_xp())
	
func _show_base_menu(val:bool):
	title.visible = val
	baseMenuUI.visible = val
	if val:
		GameGlobals.change_state(GameGlobals.STATES.MAIN_MENU)

# SETTINGS
func _on_music_on():
	musicOffButton.visible = true
	musicOnButton.visible = false
	musicOffButton.disabled = false
	musicOnButton.disabled = true
	GameGlobals.audioManager.set_as_disabled(true)

func _on_music_off():
	musicOffButton.visible = false
	musicOnButton.visible = true
	musicOffButton.disabled = true
	musicOnButton.disabled = false
	GameGlobals.audioManager.set_as_disabled(false)

# KEYBOARD FOCUS
var _keyboardFocusList:Array[Button]
var _keyboardFocusIdx:int
var _prevFocusedButton:Button
var _timeSinceLastInput:float

func _setup_keyboard_focus():
	_keyboardFocusList.clear()
	if GameGlobals.is_in_state(GameGlobals.STATES.BATTLE):
		_keyboardFocusList.append(backToGameButton)
		_keyboardFocusList.append(backToStartMenuButton)
	else:
		if !PlayerDataManager.is_new_player():
			_keyboardFocusList.append(continueGameButton)
		_keyboardFocusList.append(newGameButton)
		_keyboardFocusList.append(exitGameButton)
	_update_keyboard_focus()

func _input(event: InputEvent) -> void:
	if _timeSinceLastInput>0 and GlobalTimer.get_time_since(_timeSinceLastInput)<0.25:
		return
		
	if GameGlobals.is_in_state(GameGlobals.STATES.MAIN_MENU) or GameGlobals.is_in_substate(GameGlobals.SUB_STATES.IN_BATTLE_BACK_MENU):
		if _keyboardFocusList.is_empty():
			return
			
		if event.is_action_pressed(Constants.INPUT_MOVE_UP):
			_keyboardFocusIdx = _keyboardFocusIdx - 1
			_update_keyboard_focus()
		elif event.is_action_pressed(Constants.INPUT_MOVE_DOWN):
			_keyboardFocusIdx = _keyboardFocusIdx + 1
			_update_keyboard_focus()
			
		if event.is_action_pressed(Constants.INPUT_MENU_ACCEPT):
			_keyboardFocusList[_keyboardFocusIdx].emit_signal("button_up")
		
func _update_keyboard_focus():
	if _keyboardFocusIdx<0:
		_keyboardFocusIdx = 0
	elif _keyboardFocusIdx>_keyboardFocusList.size()-1:
		_keyboardFocusIdx = _keyboardFocusList.size()-1
		
	if _prevFocusedButton!=null and _prevFocusedButton!=_keyboardFocusList[_keyboardFocusIdx]:
		_prevFocusedButton.modulate = Color.WHITE
	_keyboardFocusList[_keyboardFocusIdx].modulate = Color.YELLOW
	_prevFocusedButton = _keyboardFocusList[_keyboardFocusIdx]
	
	_timeSinceLastInput = GlobalTimer.get_current_time()
