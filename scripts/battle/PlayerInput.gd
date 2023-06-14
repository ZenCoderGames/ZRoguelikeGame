# PlayerInput.gd

extends Node

var player:PlayerCharacter
var disableInput:bool = true
var playerMoveAction:ActionMove
var inputDelay:float = 0.0
var blockInputsForTurn:bool

func _ready():
	GameEventManager.connect("OnDungeonInitialized",Callable(self,"_on_dungeon_init"))
	GameEventManager.connect("OnCleanUpForDungeonRecreation",Callable(self,"_on_cleanup_for_dungeon"))
	GameEventManager.connect("OnNewLevelLoaded",Callable(self,"_on_new_level_loaded"))
	UIEventManager.connect("OnMainMenuOn",Callable(self,"on_main_menu_on"))
	UIEventManager.connect("OnMainMenuOff",Callable(self,"on_main_menu_off"))
	CombatEventManager.connect("OnPlayerTurnCompleted",Callable(self,"_on_player_turn_completed"))
	CombatEventManager.connect("OnEndTurn",Callable(self,"_on_end_turn")) 
	CombatEventManager.connect("OnTouchButtonPressed",Callable(self,"_on_touch_button_pressed"))
	CombatEventManager.connect("OnSkipTurnPressed",Callable(self,"_on_skip_turn_pressed"))

func _on_dungeon_init():
	_init_for_level()
	player.connect("OnDeath",Callable(self,"_on_player_death"))

func _on_new_level_loaded():
	_init_for_level()

func _init_for_level():
	disableInput = false
	blockInputsForTurn = false

	player = GameGlobals.dungeon.player
	playerMoveAction = player.moveAction

func _on_player_death():
	disableInput = true
	blockInputsForTurn = false
	player.disconnect("OnDeath",Callable(self,"_on_player_death"))

func on_main_menu_on():
	disableInput = true

func on_main_menu_off():
	disableInput = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(Constants.INPUT_EXIT_GAME):
		get_tree().quit()

	if player==null or !is_instance_valid(player):
		return
	
	if disableInput:
		return

	if blockInputsForTurn:
		return
	
	if player.isDead:
		return

	# skip turn
	if event.is_action_pressed(Constants.INPUT_SKIP_TURN):
		_on_skip_turn_pressed()
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
	blockInputsForTurn = false ## used to be true
	
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
	if player.can_skip_turn():
		player.skip_turn()
	else:
		CombatEventManager.emit_signal("OnDetailInfoShow", str("Hold Move On Cooldown (", player.get_skip_turn_cooldown(),")"), 1)

func _on_cleanup_for_dungeon(fullRefreshDungeon:bool=true):
	if fullRefreshDungeon:
		player.disconnect("OnDeath",Callable(self,"_on_player_death"))
