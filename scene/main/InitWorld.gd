# InitWorld.gd

extends Node2D

const Player := preload("res://sprite/PC.tscn")
const Floor := preload("res://sprite/Floor.tscn")

var _new_GroupName := preload("res://library/GroupName.gd").new()
var _new_ConvertCoord := preload("res://library/ConvertCoord.gd").new()
var _new_DungeonSize := preload("res://library/DungeonSize.gd").new()

func _ready() -> void:
	_init_room()

func _init_room():
	_init_floor()
	_init_player()
	
func _init_floor():
	for r in _new_DungeonSize.MAX_X:
		for c in _new_DungeonSize.MAX_Y:
			_create_sprite(str(r) + "_" + str(c), Floor, _new_GroupName.room_floor, r, c)  
	
func _init_player():
	_create_sprite("pc", Player, _new_GroupName.pc, 0, 0)

func _create_sprite(name : String, prefab: PackedScene, group: String, x: int, y: int,
		x_offset: int = 0, y_offset: int = 0) -> void:
	var new_sprite := prefab.instance() as Sprite
	new_sprite.position = _new_ConvertCoord.index_to_vector(x, y, x_offset, y_offset)
	new_sprite.name = name
	new_sprite.add_to_group(group)

	add_child(new_sprite)
	pass
