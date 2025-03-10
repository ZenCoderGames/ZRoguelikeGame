extends Node

var dungeon:Dungeon
var battleInstance:BattleInstance
var dataManager:DungeonDataManager
var effectManager:EffectManager
var audioManager:AudioManager
var currentSelectedHero:CharacterData

enum STATES { MAIN_MENU, CHARACTER_SELECT, SKILL_TREE, LEVEL_SELECT, BATTLE }
enum SUB_STATES { NONE, IN_BATTLE_MENU, IN_BATTLE_BACK_MENU, IN_POP_UP, VICTORY, DEFEAT }
var _currentState:STATES = STATES.MAIN_MENU
var _currentSubState:SUB_STATES = SUB_STATES.NONE

func _init():
	create_data_manager()

func set_dungeon(dungeonObj:Dungeon):
	dungeon = dungeonObj

func set_battle_instance(battleInstanceObj:BattleInstance):
	battleInstance = battleInstanceObj

func create_data_manager():
	dataManager = DungeonDataManager.new()

func set_effect_manager(effectManagerObj:EffectManager):
	effectManager = effectManagerObj

func set_audio_manager(audioManagerObj:AudioManager):
	audioManager = audioManagerObj

# STATES
func is_in_state(state):
	return _currentState == state

func change_state(state):
	_currentState = state
	change_substate(GameGlobals.SUB_STATES.NONE)

# SUB_STATES
func is_in_substate(substate):
	return _currentSubState == substate

func change_substate(substate):
	_currentSubState = substate
