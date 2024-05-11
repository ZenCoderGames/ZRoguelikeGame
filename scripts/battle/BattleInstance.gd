extends Node

class_name BattleInstance

@onready var view:BattleView = $"%View"
@onready var mainMenuUI:MainMenuUI = $"%MainMenuUI"
@onready var screenFade:Panel = $"%ScreenFade"

# VARIANTS
@export var startWithClasses:bool
@export var doorsStayOpenDuringBattle:bool
@export var useLevelScalingOnEnemies:bool
@export var usePopUpEquipment:bool
# DEBUG
@export var debugLevelId:String
@export var debugLevelScaling:int
@export var debugStartAtEndRoom:bool
@export var debugShowAllRooms:bool
@export var pauseAIMovement:bool
@export var pauseAIAttack:bool
@export var dontSpawnEnemies:bool
@export var debugSpawnEnemyEncounter:String
@export var dontSpawnObstacles:bool
@export var dontSpawnItems:bool
@export var debugSpawnItems:Array # (Array, String)
@export var debugSpawnSharedUpgrade:bool
@export var debugSpawnClassSpecificUpgrade:bool
@export var debugSpawnHybridUpgrade:bool
@export var debugSpawnVendor:String
@export var debugSouls:int
@export var setPlayerInvulnerable:bool
@export var setEnemiesInvulnerable:bool
@export var debugAbilities:Array # (Array, String)
@export var debugPassives:Array # (Array, String)
@export var debugStatusEffects:Array # (Array, String)

var firstTimeDungeon:bool = false

var currentDungeonIdx:int
var currentLevelData:LevelData

func _init():
	GameGlobals.set_battle_instance(self)

func _ready():
	currentDungeonIdx = 0

	GameEventManager.connect("OnCharacterSelected",Callable(self,"_on_character_chosen"))
	
	mainMenuUI.visible = true
	GameEventManager.connect("OnReadyToBattle",Callable(self,"_on_new_game"))

	await get_tree().create_timer(0.1).timeout
	GameEventManager.emit_signal("OnGameInitialized")

func _on_character_chosen(charData):
	GameGlobals.dataManager.on_character_chosen(charData)

func _on_new_game(levelData:LevelData):
	GameGlobals.dataManager.init_dungeon_data(levelData)
	currentLevelData = levelData
	if !firstTimeDungeon:
		_create_dungeon()
	else:
		recreate_dungeon(0)

func _create_dungeon():
	_toggle_main_menu()
	GameGlobals.dungeon.init(GameGlobals.dataManager.dungeonDataList[currentDungeonIdx])
	_shared_dungeon_init()
	firstTimeDungeon = true
	GameEventManager.emit_signal("OnDungeonInitialized")

	# debug
	if GameGlobals.battleInstance.debugAbilities.size()>0:
		for debugAbility in GameGlobals.battleInstance.debugAbilities:
			GameGlobals.dungeon.player.add_ability(GameGlobals.dataManager.get_ability_data(debugAbility))
	if GameGlobals.battleInstance.debugPassives.size()>0:
		for debugPassive in GameGlobals.battleInstance.debugPassives:
			GameGlobals.dungeon.player.add_passive(GameGlobals.dataManager.get_passive_data(debugPassive))
	if GameGlobals.battleInstance.debugStatusEffects.size()>0:
		for debugStatusEffect in GameGlobals.battleInstance.debugStatusEffects:
			GameGlobals.dungeon.player.add_status_effect(GameGlobals.dungeon.player, GameGlobals.dataManager.get_status_effect_data(debugStatusEffect))

func recreate_dungeon(newDungeonIdx):
	var isNewDungeon:bool = newDungeonIdx==0
	currentDungeonIdx = newDungeonIdx
	GameEventManager.emit_signal("OnCleanUpForDungeonRecreation", isNewDungeon)
	GameGlobals.dungeon.init(GameGlobals.dataManager.dungeonDataList[newDungeonIdx])
	await get_tree().create_timer(0.1).timeout
	_shared_dungeon_init(newDungeonIdx==0)
	if isNewDungeon:
		_toggle_main_menu()
		GameEventManager.emit_signal("OnDungeonInitialized")
	else:
		GameEventManager.emit_signal("OnNewLevelLoaded")

func _shared_dungeon_init(recreatePlayer:bool=true):
	# Clean up all in battle events
	#CombatEventManager.clean_up()
	#HitResolutionManager.clean_up()

	GameGlobals.dungeon.create(recreatePlayer)
	#_toggle_main_menu()
	GameGlobals.dungeon.player.connect("OnDeathFinal",Callable(self,"_on_player_death"))
	GameGlobals.dungeon.player.connect("OnPlayerReachedExit",Callable(self,"_on_dungeon_completed"))
	GameGlobals.dungeon.player.connect("OnPlayerReachedEnd",Callable(self,"_on_player_victory"))
	
	await get_tree().create_timer(0.2).timeout
	
	screenFade.visible = false

func _toggle_main_menu():
	mainMenuUI.visible = !mainMenuUI.visible
	if mainMenuUI.visible:
		mainMenuUI.show_menu()
		UIEventManager.emit_signal("OnMainMenuOn")
	else:
		UIEventManager.emit_signal("OnMainMenuOff")

func _on_player_death():
	GameEventManager.emit_signal("OnDungeonExited", false)

# Clean up and load a new floor
func _on_dungeon_completed():
	screenFade.visible = true
	GameEventManager.emit_signal("OnDungeonFloorCompleted")
	
	await get_tree().create_timer(0.05).timeout

	currentDungeonIdx = currentDungeonIdx+1
	if currentDungeonIdx<GameGlobals.dataManager.dungeonDataList.size():
		recreate_dungeon(currentDungeonIdx)

func _on_player_victory():
	GameEventManager.emit_signal("OnDungeonExited", true)

# HELPERS
func get_current_level():
	return currentDungeonIdx+1

func is_last_level():
	return currentDungeonIdx == GameGlobals.dataManager.dungeonDataList.size()-1
