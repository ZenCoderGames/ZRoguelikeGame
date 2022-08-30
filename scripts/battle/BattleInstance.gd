extends Node

class_name BattleInstance

onready var view:BattleView = $"%View"
onready var mainMenuUI:MainMenuUI = $"%MainMenuUI"

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

func _init():
	_init_dungeon_data()
	Dungeon.init(self, dungeonDataList[0])

func _ready():
	mainMenuUI.visible = true
	mainMenuUI.connect("OnNewGamePressed", self, "_on_new_game")

func _on_new_game():
	if !firstTimeDungeon:
		_create_dungeon()
	else:
		restart_dungeon()

func _create_dungeon():
	_shared_dungeon_init()
	firstTimeDungeon = true
	emit_signal("OnDungeonInitialized")

func restart_dungeon():
	Dungeon.clean_up()
	_shared_dungeon_init()
	emit_signal("OnDungeonRecreated")

func _shared_dungeon_init():
	Dungeon.create()
	onGameOver = false
	_toggle_main_menu()
	Dungeon.player.connect("OnDeath", self, "_on_game_over")

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

# DUNGEONS
func _init_dungeon_data():
	var data = Utils.load_data_from_file("resource/dungeons.json")
	var dungeonDataJSList:Array = data["dungeons"]
	for dungeonDataJS in dungeonDataJSList:
		var newDungeonData = DungeonData.new(dungeonDataJS)
		dungeonDataList.append(newDungeonData)
