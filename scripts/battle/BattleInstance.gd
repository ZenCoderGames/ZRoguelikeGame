extends Node

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
export var setPlayerInvulnerable:bool
export var debugShowAllRooms:bool
export var debugStartRoomColor:Color
export var debugCriticalPathRoomColor:Color
export var debugEndRoomColor:Color

signal OnDungeonInitialized()
signal OnDungeonRecreated()

func _init():
	Dungeon.init(self)

func _ready():
	yield(get_tree(),"idle_frame")
	_create_dungeon()
	emit_signal("OnDungeonInitialized")

func _create_dungeon():
	Dungeon.create()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(Constants.INPUT_RESET_DUNGEON):
		Dungeon.clean_up()
		Dungeon.create()
		emit_signal("OnDungeonRecreated")
