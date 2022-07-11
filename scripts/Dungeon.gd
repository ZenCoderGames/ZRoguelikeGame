# Dungeon.gd

extends Node2D

const Player := preload("res://entity/Player.tscn")
const Room := preload("res://scripts/battle/Room.gd")

# signals
signal OnPlayerCreated(newPlayer)

var currentRoom = null

func _ready() -> void:
	yield(get_tree(), "idle_frame")
	_init_room()
	_init_player()

func _init_room():
	currentRoom = Room.new(15, 20, 50, 54)
	currentRoom.populate_room()

func _init_player():
	var cell = currentRoom.get_random_connector_cell()
	var player:Node = Utils.create_scene("player", Player, Constants.pc, cell)
	player.init(cell, 100, 10)
	emit_signal("OnPlayerCreated", player)
