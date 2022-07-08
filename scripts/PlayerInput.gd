# PlayerInput.gd

extends Node

var _new_InputName := preload("res://scripts/library/InputTypes.gd").new()
var _new_ConvertCoord := preload("res://scripts/library/ConvertCoord.gd").new()
var _new_DungeonSize := preload("res://scripts/library/DungeonSize.gd").new()

var player:Sprite = null

func _ready():
	var __  = get_node("..").connect("OnPlayerCreated", self,
			"_onPlayerCreated")

func _unhandled_input(event: InputEvent) -> void:
	var source:Array = _new_ConvertCoord.vector_to_array(player.position)
	var x:int = source[0]
	var y:int = source[1]
	
	if event.is_action_pressed(_new_InputName.MOVE_LEFT):
		x -= 1
	elif event.is_action_pressed(_new_InputName.MOVE_RIGHT):
		x += 1
	elif event.is_action_pressed(_new_InputName.MOVE_UP):
		y -= 1
	elif event.is_action_pressed(_new_InputName.MOVE_DOWN):
		y += 1

	if x>=0 and y>=0 and x<_new_DungeonSize.MAX_X and y<_new_DungeonSize.MAX_Y:
		player.position = _new_ConvertCoord.index_to_vector(x, y)

	if event.is_action_pressed(_new_InputName.EXIT_GAME):
		get_tree().quit()
		

func _onPlayerCreated(newPlayer:Sprite):
	player = newPlayer
