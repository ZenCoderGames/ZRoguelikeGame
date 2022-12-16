# PlayerInput.gd

extends Node

var player:PlayerCharacter
var disableInput:bool = true
var playerMoveAction:ActionMove
var inputDelay:float = 0.0
var blockInputsForTurn:bool

func _ready():
	Dungeon.connect("OnPlayerCreated", self, "_register_player") 
	Dungeon.battleInstance.connect("OnDungeonInitialized", self, "_on_dungeon_init")
	Dungeon.battleInstance.connect("OnMainMenuOn", self, "on_main_menu_on")
	Dungeon.battleInstance.connect("OnMainMenuOff", self, "on_main_menu_off")
	Dungeon.connect("OnPlayerTurnCompleted", self, "_on_player_turn_completed")
	Dungeon.connect("OnEndTurn", self, "_on_end_turn") 
	
func _register_player(playerRef):
	player = playerRef
	player.connect("OnDeath", self, "_on_player_death")

func _on_dungeon_init():
	disableInput = false
	playerMoveAction = player.moveAction

func _on_player_death():
	disableInput = true
	player.disconnect("OnDeath", self, "_on_player_death")

func on_main_menu_on():
	disableInput = true

func on_main_menu_off():
	disableInput = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(Constants.INPUT_EXIT_GAME):
		get_tree().quit()

	if disableInput || blockInputsForTurn:
		return
	
	if player.isDead:
		return

	# movement
	var x:int = 0
	var y:int = 0
	
	if event.is_action_pressed(Constants.INPUT_MOVE_LEFT):
		x = -1
	elif event.is_action_pressed(Constants.INPUT_MOVE_RIGHT):
		x = 1
	elif event.is_action_pressed(Constants.INPUT_MOVE_UP):
		y = -1
	elif event.is_action_pressed(Constants.INPUT_MOVE_DOWN):
		y = 1

	if player != null and !(x==0 and y==0):
		if playerMoveAction.can_execute():
			player.move(x, y)

func _on_player_turn_completed():
	blockInputsForTurn = true
	
func _on_end_turn():
	blockInputsForTurn = false
