# Character.gd
extends Node

var health: int = 0
var damage: int = 0
var cell

var currentRoom = null
var prevRoom = null

signal OnCharacterMove(x, y)

func init(hlth, dmg):
	health = hlth
	damage = dmg

func move(x, y):
	var newR:int = cell.row + y
	var newC:int = cell.col + x
	
	var success:bool = cell.room.move_entity(self, cell, newR, newC)
	if success:
		emit_signal("OnCharacterMove", x, y)

func move_to_cell(newCell):
	cell = newCell
	self.position = Vector2(cell.pos.x, cell.pos.y)
	if currentRoom != cell.room:
		prevRoom = currentRoom
	currentRoom = cell.room

# HELPERS
func is_in_room(room):
	return currentRoom == room

func is_prev_room(room):
	return prevRoom == room
