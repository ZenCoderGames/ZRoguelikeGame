# Character.gd

extends Node

var _new_ConvertCoord := preload("res://scripts/library/ConvertCoord.gd").new()
var _new_DungeonSize := preload("res://scripts/library/DungeonSize.gd").new()

var posX: int = 0
var posY: int = 0
var health: int = 0
var damage: int = 0

func init(x, y, hlth, dmg):
	posX = x
	posY = y
	health = hlth
	damage = dmg

func move(x, y):
	var source:Array = _new_ConvertCoord.vector_to_array(self.position)
	var srcX:int = source[0]
	var srcY:int = source[1]
	
	var newX:int = srcX + x
	var newY:int = srcY + y
	
	if newX>=0 and newY>=0 and newX<_new_DungeonSize.MAX_X and newY<_new_DungeonSize.MAX_Y:
		self.position = _new_ConvertCoord.index_to_vector(newX, newY)
		posX = newX
		posY = newY
		
func getPosX():
	return posX

func getPosY():
	return posY
