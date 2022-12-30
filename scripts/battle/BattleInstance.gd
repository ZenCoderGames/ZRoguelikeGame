extends Node

class_name BattleInstance

onready var view:BattleView = $"%View"
onready var mainMenuUI:MainMenuUI = $"%MainMenuUI"
onready var screenFade:Panel = $"%ScreenFade"
onready var victoryUI:PanelContainer = $"%VictoryUI"

# DEBUG
export var doorsStayOpenDuringBattle:bool
export var pauseAIMovement:bool
export var pauseAIAttack:bool
export var dontSpawnEnemies:bool
export var debugSpawnEnemyEncounter:String
export var dontSpawnObstacles:bool
export var dontSpawnItems:bool
export var debugSpawnItemInFirstRoom:String
export var setPlayerInvulnerable:bool
export var debugGiveAbility:String
export var debugShowAllRooms:bool

var firstTimeDungeon:bool = false
var onGameOver:bool

var currentDungeonIdx:int

func _init():
	GameGlobals.set_battle_instance(self)

func _ready():
	currentDungeonIdx = 0
	GameGlobals.dungeon.init(GameGlobals.dataManager.dungeonDataList[currentDungeonIdx])

	GameEventManager.connect("OnCharacterSelected", self, "_on_character_chosen")
	
	mainMenuUI.visible = true
	GameEventManager.connect("OnReadyToBattle", self, "_on_new_game")

func _on_character_chosen(charData):
	GameGlobals.dataManager.on_character_chosen(charData)

func _on_new_game():
	if !firstTimeDungeon:
		_create_dungeon()
	else:
		recreate_dungeon(0)

func _create_dungeon():
	_shared_dungeon_init()
	firstTimeDungeon = true
	GameEventManager.emit_signal("OnDungeonInitialized")

	if !debugGiveAbility.empty():
		GameGlobals.dungeon.player.add_ability(GameGlobals.dataManager.get_ability_data(debugGiveAbility))

func recreate_dungeon(newDungeonIdx):
	currentDungeonIdx = newDungeonIdx
	GameGlobals.dungeon.clean_up(newDungeonIdx==0)
	GameGlobals.dungeon.init(GameGlobals.dataManager.dungeonDataList[newDungeonIdx])
	_shared_dungeon_init(newDungeonIdx==0)
	if newDungeonIdx==0:
		GameEventManager.emit_signal("OnDungeonRecreated")

func _shared_dungeon_init(recreatePlayer:bool=true):
	GameGlobals.dungeon.create(recreatePlayer)
	onGameOver = false
	_toggle_main_menu()
	GameGlobals.dungeon.player.connect("OnDeath", self, "_on_game_over")
	GameGlobals.dungeon.player.connect("OnPlayerReachedExit", self, "_on_dungeon_completed")
	GameGlobals.dungeon.player.connect("OnPlayerReachedEnd", self, "_on_game_end")
	
	yield(get_tree().create_timer(0.2), "timeout")
	
	screenFade.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if onGameOver:
		return

	if event.is_action_pressed(Constants.INPUT_TOGGLE_INVENTORY):
		CombatEventManager.emit_signal("OnToggleInventory")

	if event.is_action_pressed(Constants.INPUT_TOGGLE_MAIN_MENU):
		_toggle_main_menu()

func _toggle_main_menu():
	mainMenuUI.visible = !mainMenuUI.visible
	if mainMenuUI.visible:
		mainMenuUI.show_menu()
		GameEventManager.emit_signal("OnMainMenuOn")
	else:
		GameEventManager.emit_signal("OnMainMenuOff")

func _on_game_over():
	onGameOver = true
	GameGlobals.dungeon.isDungeonFinished = true
	GameEventManager.emit_signal("OnGameOver")

func _on_dungeon_completed():
	screenFade.visible = true
	_toggle_main_menu()

	GameGlobals.dungeon.isDungeonFinished = true
	
	yield(get_tree().create_timer(0.05), "timeout")

	currentDungeonIdx = currentDungeonIdx+1
	if currentDungeonIdx<GameGlobals.dataManager.dungeonDataList.size():
		recreate_dungeon(currentDungeonIdx)

func _on_game_end():
	victoryUI.visible = true
	GameGlobals.dungeon.isDungeonFinished = true
	yield(get_tree().create_timer(0.5), "timeout")
	_toggle_main_menu()

func back_to_menu_from_victory():
	_toggle_main_menu()
	victoryUI.visible = false
	GameGlobals.dungeon.isDungeonFinished = false

# HELPERS
func get_current_level():
	return currentDungeonIdx+1

func is_last_level():
	return currentDungeonIdx == GameGlobals.dataManager.dungeonDataList.size()-1
