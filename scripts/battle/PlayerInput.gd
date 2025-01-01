# PlayerInput.gd

extends Node

var player:PlayerCharacter
var disableInput:bool = true
var playerMoveAction:ActionMove
var inputDelay:float = 0.0
var blockInputsForTurn:bool
var blockMovementInputsForTurn:bool
var _timeSinceLastInput:float
var _cachedTimeSinceLastInput:float
var _cachedX:int
var _cachedY:int
var _specialForSelection:Special

func _ready():
	GameEventManager.connect("OnDungeonInitialized",Callable(self,"_on_dungeon_init"))
	GameEventManager.connect("OnCleanUpForDungeonRecreation",Callable(self,"_on_cleanup_for_dungeon"))
	GameEventManager.connect("OnNewLevelLoaded",Callable(self,"_on_new_level_loaded"))
	UIEventManager.connect("OnMainMenuOn",Callable(self,"on_menu_on"))
	UIEventManager.connect("OnMainMenuOff",Callable(self,"on_menu_off"))
	UIEventManager.connect("OnSelectionMenuOn",Callable(self,"on_menu_on"))
	UIEventManager.connect("OnSelectionMenuOff",Callable(self,"on_menu_off"))
	CombatEventManager.connect("OnPlayerTurnCompleted",Callable(self,"_on_player_turn_completed"))
	CombatEventManager.connect("OnStartTurn",Callable(self,"_on_start_turn")) 
	CombatEventManager.connect("OnEndTurn",Callable(self,"_on_end_turn")) 
	CombatEventManager.connect("OnTouchButtonPressed",Callable(self,"_on_touch_button_pressed"))
	CombatEventManager.connect("OnSkipTurnPressed",Callable(self,"_on_skip_turn_pressed"))
	CombatEventManager.connect("OnPlayerSpecialAbilityActivated",Callable(self,"_on_special_activated"))
	CombatEventManager.connect("OnPlayerSpecialAbilityCompleted",Callable(self,"_on_special_completed"))
	CombatEventManager.connect("OnPlayerSpecialSelectionActivated",Callable(self,"_on_special_selection_activated"))

func _on_dungeon_init():
	_init_for_level()
	player.connect("OnDeathFinal",Callable(self,"_on_player_death"))

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
	player.disconnect("OnDeathFinal",Callable(self,"_on_player_death"))

func on_menu_on():
	disableInput = true

func on_menu_off():
	disableInput = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(Constants.INPUT_EXIT_GAME):
		GameEventManager.emit_signal("OnBackButtonPressed")
		return
		
	_debug_inputs(event)

	if player==null or !is_instance_valid(player):
		return
	
	if disableInput:
		return
	
	if player.isDead || player.is_reviving():
		return

	# skip turn
	if event.is_action_pressed(Constants.INPUT_SKIP_TURN):
		_on_skip_turn_pressed()
		return

	if event.is_action_pressed(Constants.INPUT_TOGGLE_INVENTORY):
		CombatEventManager.emit_signal("OnToggleInventory")

	# special selection
	if _specialForSelection!=null:
		_process_special_selection(event)
		return

	# movement
	if blockMovementInputsForTurn:
		return
		
	var x:int = 0
	var y:int = 0

	if !player.currentRoom.is_in_combat() and _timeSinceLastInput>0 and\
		GlobalTimer.get_time_since(_timeSinceLastInput)>Constants.HOLD_TIME_THRESHOLD:
		if event.is_action(Constants.INPUT_MOVE_LEFT):
			x = -1
			_cachedX = -1
		elif event.is_action(Constants.INPUT_MOVE_RIGHT):
			x = 1
			_cachedX = 1
		elif event.is_action(Constants.INPUT_MOVE_UP):
			y = -1
			_cachedY = -1
		elif event.is_action(Constants.INPUT_MOVE_DOWN):
			y = 1
			_cachedY = 1
	else:
		if event.is_action_pressed(Constants.INPUT_MOVE_LEFT):
			x = -1
			_cachedX = -1
			_cachedY = 0
			_timeSinceLastInput = GlobalTimer.get_current_time()
			_cachedTimeSinceLastInput = _timeSinceLastInput
		elif event.is_action_pressed(Constants.INPUT_MOVE_RIGHT):
			x = 1
			_cachedX = 1
			_cachedY = 0
			_timeSinceLastInput = GlobalTimer.get_current_time()
			_cachedTimeSinceLastInput = _timeSinceLastInput
		elif event.is_action_pressed(Constants.INPUT_MOVE_UP):
			y = -1
			_cachedY = -1
			_cachedX = 0
			_timeSinceLastInput = GlobalTimer.get_current_time()
			_cachedTimeSinceLastInput = _timeSinceLastInput
		elif event.is_action_pressed(Constants.INPUT_MOVE_DOWN):
			y = 1
			_cachedY = 1
			_cachedX = 0
			_timeSinceLastInput = GlobalTimer.get_current_time()
			_cachedTimeSinceLastInput = _timeSinceLastInput

	if event.is_action_released(Constants.INPUT_MOVE_LEFT) or\
		event.is_action_released(Constants.INPUT_MOVE_RIGHT) or\
		event.is_action_released(Constants.INPUT_MOVE_UP) or\
		event.is_action_released(Constants.INPUT_MOVE_DOWN):
		_timeSinceLastInput = 0

	if blockInputsForTurn:
		return

	if player != null and (x!=0 or y!=0):
		if playerMoveAction.can_execute():
			if player.currentRoom.is_in_combat():
				blockInputsForTurn = true
			var success:bool = player.move(x, y)
			if !success:
				blockInputsForTurn = false
			_cachedX = 0
			_cachedY = 0

func _process(_delta):
	if player == null:
		return

	if !player.currentRoom.is_in_combat() or\
		GlobalTimer.get_current_time() - _cachedTimeSinceLastInput>Constants.INPUT_CACHE_TIME_THRESHOLD:
		_cachedX = 0
		_cachedY = 0

	if blockInputsForTurn:
		return
	
	if (_cachedX!=0 or _cachedY!=0):
		if playerMoveAction.can_execute():
			if player.currentRoom.is_in_combat():
				blockInputsForTurn = true
			var success:bool = player.move(_cachedX, _cachedY)
			if !success:
				blockInputsForTurn = false
			_cachedX = 0
			_cachedY = 0

func _on_player_turn_completed():
	pass
	#blockInputsForTurn = true ## used to be false
	
func _on_start_turn():
	blockInputsForTurn = false

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
	if fullRefreshDungeon and player!=null:
		player.disconnect("OnDeathFinal",Callable(self,"_on_player_death"))

func _debug_inputs(event: InputEvent):
	if event.is_action_pressed("debug_victory"):
		player.end_dungeon()
	if event.is_action_pressed("debug_fail"):
		GameEventManager.emit_signal("OnDungeonExited", false)
	if event.is_action_pressed("debug_add_souls_100"):
		PlayerDataManager.add_current_xp(100)
	if event.is_action_pressed("debug_remove_souls_20"):
		PlayerDataManager.remove_current_xp(20)

# SPECIAL
func _on_special_activated(_special:Special):
	blockMovementInputsForTurn = true

func _on_special_completed(_special:Special):
	blockMovementInputsForTurn = false

func _on_special_selection_activated(_special:Special):
	_specialForSelection = _special

func _process_special_selection(event: InputEvent):
	if event.is_action_pressed(Constants.INPUT_MOVE_LEFT):
		_on_special_selection_completed(Constants.INPUT_MOVE_LEFT)
	elif event.is_action_pressed(Constants.INPUT_MOVE_RIGHT):
		_on_special_selection_completed(Constants.INPUT_MOVE_RIGHT)
	elif event.is_action_pressed(Constants.INPUT_MOVE_UP):
		_on_special_selection_completed(Constants.INPUT_MOVE_UP)
	elif event.is_action_pressed(Constants.INPUT_MOVE_DOWN):
		_on_special_selection_completed(Constants.INPUT_MOVE_DOWN)

func _on_special_selection_completed(dirn:String):
	CombatEventManager.emit_signal("OnPlayerSpecialSelectionCompleted", _specialForSelection, dirn)
	_specialForSelection = null
