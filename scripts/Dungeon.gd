# Dungeon.gd

extends Node2D

const Player := preload("res://sprite/PC.tscn")
const Room := preload("res://scripts/battle/Room.gd")

# signals
signal OnPlayerCreated(newPlayer)

var currentRoom = null

func _ready() -> void:
	yield(get_tree(), "idle_frame")
	_init_room()
	_init_player()

func _init_room():
	currentRoom = Room.new()
	currentRoom.populate_room()

func _init_player():
	var pc:Node = Utils.create_scene("pc", Player, Constants.pc, currentRoom.get_cell(0, 0))
	pc.init(currentRoom.get_cell(0, 0), 100, 10)
	emit_signal("OnPlayerCreated", pc)
