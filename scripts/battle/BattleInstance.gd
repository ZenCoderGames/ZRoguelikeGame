extends Node

class_name BattleInstance

onready var view:BattleView = $"%View"
onready var mainMenuUI:MainMenuUI = $"%MainMenuUI"

export var showWallColor:Color
export var showFloorColor:Color
export var dimWallColor:Color
export var dimFloorColor:Color
export var playerDamageColor:Color
export var enemyDamageColor:Color
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
export var debugStartRoomColor:Color
export var debugCriticalPathRoomColor:Color
export var debugEndRoomColor:Color

signal OnDungeonInitialized()
signal OnDungeonRecreated()
signal OnToggleInventory()
signal OnMainMenuOn()
signal OnMainMenuOff()

var onGameOver:bool

func _init():
	Dungeon.init(self)

func _ready():
	yield(get_tree(),"idle_frame")
	_create_dungeon()
	emit_signal("OnDungeonInitialized")

func _create_dungeon():
	_shared_dungeon_init()

func restart_dungeon():
	Dungeon.clean_up()
	_toggle_main_menu()
	_shared_dungeon_init()
	emit_signal("OnDungeonRecreated")

func _shared_dungeon_init():
	Dungeon.create()
	onGameOver = false
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
