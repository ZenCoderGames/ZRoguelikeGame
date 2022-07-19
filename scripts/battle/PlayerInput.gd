# PlayerInput.gd

extends Node

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

	if Dungeon.player != null and !(x==0 and y==0):
		Dungeon.player.move(x, y)

	if event.is_action_pressed(Constants.INPUT_EXIT_GAME):
		get_tree().quit()
