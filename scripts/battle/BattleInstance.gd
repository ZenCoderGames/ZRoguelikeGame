extends Node

class_name BattleInstance

onready var view:BattleView = $"%View"
onready var mainMenuUI:MainMenuUI = $"%MainMenuUI"
onready var screenFade:Panel = $"%ScreenFade"
onready var victoryUI:PanelContainer = $"%VictoryUI"

export var timeBetweenMoves:float

# DEBUG
export var pauseAIMovement:bool
export var pauseAIAttack:bool
export var dontSpawnEnemies:bool
export var debugSpawnEnemyInFirstRoom:String
export var dontSpawnItems:bool
export var debugSpawnItemInFirstRoom:String
export var setPlayerInvulnerable:bool
export var debugShowAllRooms:bool

signal OnDungeonInitialized()
signal OnDungeonRecreated()
signal OnToggleInventory()
signal OnMainMenuOn()
signal OnMainMenuOff()

var firstTimeDungeon:bool = false
var onGameOver:bool

var dungeonDataList:Array
var currentDungeonIdx:int

func _init():
	currentDungeonIdx = 0
	_init_dungeon_data()
	Dungeon.init(self, dungeonDataList[currentDungeonIdx])

func _ready():
	mainMenuUI.visible = true
	mainMenuUI.connect("OnNewGamePressed", self, "_on_new_game")

func _on_new_game():
	if !firstTimeDungeon:
		_create_dungeon()
	else:
		recreate_dungeon(0)

func _create_dungeon():
	_shared_dungeon_init()
	firstTimeDungeon = true
	emit_signal("OnDungeonInitialized")

func recreate_dungeon(newDungeonIdx):
	currentDungeonIdx = newDungeonIdx
	Dungeon.clean_up(newDungeonIdx==0)
	Dungeon.init(self, dungeonDataList[newDungeonIdx])
	_shared_dungeon_init(newDungeonIdx==0)
	if newDungeonIdx==0:
		emit_signal("OnDungeonRecreated")

func _shared_dungeon_init(recreatePlayer:bool=true):
	Dungeon.create(recreatePlayer)
	onGameOver = false
	_toggle_main_menu()
	Dungeon.player.connect("OnDeath", self, "_on_game_over")
	Dungeon.player.connect("OnPlayerReachedExit", self, "_on_dungeon_completed")
	Dungeon.player.connect("OnPlayerReachedEnd", self, "_on_game_end")
	
	yield(get_tree().create_timer(0.2), "timeout")
	
	screenFade.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if onGameOver:
		return

	if event.is_action_pressed(Constants.INPUT_TOGGLE_INVENTORY):
		emit_signal("OnToggleInventory")

	if event.is_action_pressed(Constants.INPUT_TOGGLE_MAIN_MENU):
		_toggle_main_menu()

func _toggle_main_menu():
	mainMenuUI.visible = !mainMenuUI.visible
	if mainMenuUI.visible:
		emit_signal("OnMainMenuOn")
	else:
		emit_signal("OnMainMenuOff")

func _on_game_over():
	onGameOver = true

func _on_dungeon_completed():
	screenFade.visible = true
	_toggle_main_menu()
	
	yield(get_tree().create_timer(0.2), "timeout")

	currentDungeonIdx = currentDungeonIdx+1
	if currentDungeonIdx<dungeonDataList.size():
		recreate_dungeon(currentDungeonIdx)

func _on_game_end():
	_toggle_main_menu()
	victoryUI.visible = true

# DUNGEONS
func _init_dungeon_data():
	var data = Utils.load_data_from_file("resource/dungeons.json")
	var dungeonDataJSList:Array = data["dungeons"]
	for dungeonDataJS in dungeonDataJSList:
		var newDungeonData = DungeonData.new(dungeonDataJS)
		dungeonDataList.append(newDungeonData)

# HELPERS
func get_current_level():
	return currentDungeonIdx+1

func get_max_levels():
	return dungeonDataList.size()

func is_last_level():
	return currentDungeonIdx == dungeonDataList.size()-1
