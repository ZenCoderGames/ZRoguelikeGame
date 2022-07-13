# Character.gd
extends Node

var health: int = 0
var damage: int = 0
var cell

func init(newCell, hlth, dmg):
	cell = newCell
	health = hlth
	damage = dmg

func move(x, y):
	var newR:int = cell.row + y
	var newC:int = cell.col + x
	
	cell.room.move_entity(self, cell, newR, newC)

func move_to_cell(newCell):
	cell = newCell
	self.position = Vector2(cell.pos.x, cell.pos.y)
