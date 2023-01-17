# PlayerInput.gd

extends Node

var player:PlayerCharacter
var disableInput:bool = true
var playerMoveAction:ActionMove
var inputDelay:float = 0.0
var blockInputsForTurn:bool

func _ready():
	CombatEventManager.connect("OnPlayerCreated", self, "_register_player") 
	GameEventManager.connect("OnDungeonInitialized", self, "_on_dungeon_init")
	GameEventManager.connect("OnMainMenuOn", self, "on_main_menu_on")
	GameEventManager.connect("OnMainMenuOff", self, "on_main_menu_off")
	CombatEventManager.connect("OnPlayerTurnCompleted", self, "_on_player_turn_completed")
	CombatEventManager.connect("OnEndTurn", self, "_on_end_turn") 
	CombatEventManager.connect("OnTouchButtonPressed", self, "_on_touch_button_pressed")
	CombatEventManager.connect("OnSkipTurnPressed", self, "_on_skip_turn_pressed")
	
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

	if disableInput:
		return

	if blockInputsForTurn:
		return
	
	if player.isDead:
		return

	# skip turn
	if event.is_action_pressed(Constants.INPUT_SKIP_TURN):
		player.on_turn_completed()
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

func _on_touch_button_pressed(dirn):
	var x:int = 0
	var y:int = 0
	if dirn==0:
		x = -1
	elif dirn==1:
		y = -1
	elif dirn==2:
		x = 1
	elif dirn==3:
		y = 1
	if player != null:
		if playerMoveAction.can_execute():
			player.move(x, y)

func _on_skip_turn_pressed():
	player.on_turn_completed()
