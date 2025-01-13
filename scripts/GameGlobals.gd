extends Node

var dungeon:Dungeon
var battleInstance:BattleInstance
var dataManager:DungeonDataManager
var effectManager:EffectManager
var audioManager:AudioManager

enum STATES { MAIN_MENU, CHARACTER_SELECT, SKILL_TREE, LEVEL_SELECT, BATTLE }
var _currentState:STATES = STATES.MAIN_MENU

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
