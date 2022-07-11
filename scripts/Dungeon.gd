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
	currentRoom = Room.new()
	currentRoom.populate_room()

func _init_player():
	var cell = currentRoom.get_cell(2, 1)
	var player:Node = Utils.create_scene("player", Player, Constants.pc, cell)
	player.init(cell, 100, 10)
	emit_signal("OnPlayerCreated", player)
