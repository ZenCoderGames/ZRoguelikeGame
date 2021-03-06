# PlayerInput.gd

extends Node

var player:PlayerCharacter
var disableInput:bool = true
var playerMoveAction:ActionMove

func _ready():
	Dungeon.connect("OnPlayerCreated", self, "_register_player") 
	Dungeon.battleInstance.connect("OnDungeonInitialized", self, "_on_dungeon_init")
	Dungeon.battleInstance.connect("OnDungeonRecreated", self, "_on_dungeon_init")
	
func _register_player(playerRef):
	player = playerRef
	player.connect("OnDeath", self, "_on_player_death")

func _on_dungeon_init():
	disableInput = false
	playerMoveAction = player.get_action("MOVEMENT")

func _on_player_death():
	disableInput = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(Constants.INPUT_EXIT_GAME):
		get_tree().quit()

	if disableInput:
		return
		
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
