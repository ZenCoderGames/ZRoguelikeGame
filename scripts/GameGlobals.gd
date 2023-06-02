extends Node

var dungeon:Dungeon
var battleInstance:BattleInstance
var dataManager:DungeonDataManager
var effectManager:EffectManager
var audioManager:AudioManager

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
