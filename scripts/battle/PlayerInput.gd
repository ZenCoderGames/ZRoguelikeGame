# PlayerInput.gd

extends Node

var player = null

func _ready():
	var __  = Dungeon.connect("OnPlayerCreated", self,
			"_onPlayerCreated")

func _unhandled_input(event: InputEvent) -> void:
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

	player.move(x, y)

	if event.is_action_pressed(Constants.INPUT_EXIT_GAME):
		get_tree().quit()
		

func _onPlayerCreated(newPlayer):
	player = newPlayer
