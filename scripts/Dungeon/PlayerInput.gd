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
	var x:int = 0
	var y:int = 0
	
	if event.is_action_pressed(_new_InputName.MOVE_LEFT):
		x = -1
	elif event.is_action_pressed(_new_InputName.MOVE_RIGHT):
		x = 1
	elif event.is_action_pressed(_new_InputName.MOVE_UP):
		y = -1
	elif event.is_action_pressed(_new_InputName.MOVE_DOWN):
		y = 1

	player.move(x, y)

	if event.is_action_pressed(_new_InputName.EXIT_GAME):
		get_tree().quit()
		

func _onPlayerCreated(newPlayer:Sprite):
	player = newPlayer
