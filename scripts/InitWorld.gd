# InitWorld.gd

extends Node2D

const Player := preload("res://sprite/PC.tscn")
const Floor := preload("res://sprite/Floor.tscn")
const Wall := preload("res://sprite/Wall.tscn")
const ArrowX := preload("res://sprite/ArrowX.tscn")
const ArrowY := preload("res://sprite/ArrowY.tscn")
const Dwarf := preload("res://sprite/Dwarf.tscn")

var _new_GroupName := preload("res://scripts/library/GroupName.gd").new()
var _new_ConvertCoord := preload("res://scripts/library/ConvertCoord.gd").new()
var _new_DungeonSize := preload("res://scripts/library/DungeonSize.gd").new()

# signals
signal OnPlayerCreated(newPlayer)

func _ready() -> void:
	_init_room()

func _init_room():
	_init_floor()
	_init_walls()
	_init_arrows()
	_init_enemies()
	_init_player()
	
func _init_floor():
	for r in _new_DungeonSize.MAX_X:
		for c in _new_DungeonSize.MAX_Y:
			_create_sprite(str(r) + "_" + str(c), Floor, _new_GroupName.room_floor, r, c)  

func _init_walls():
	_create_sprite("wall", Wall, _new_GroupName.room_floor, 5, 5)
	_create_sprite("wall", Wall, _new_GroupName.room_floor, 5, 6)
	_create_sprite("wall", Wall, _new_GroupName.room_floor, 5, 7)
	_create_sprite("wall", Wall, _new_GroupName.room_floor, 5, 8)
	_create_sprite("wall", Wall, _new_GroupName.room_floor, 5, 6)
	_create_sprite("wall", Wall, _new_GroupName.room_floor, 6, 6)
	_create_sprite("wall", Wall, _new_GroupName.room_floor, 7, 6)
	_create_sprite("wall", Wall, _new_GroupName.room_floor, 8, 6)
	
func _init_arrows():
	_create_sprite("arrow", ArrowY, _new_GroupName.room_floor, 7, 0, 0, -20)
	_create_sprite("arrow", ArrowX, _new_GroupName.room_floor, 0, 5, -20)
	
func _init_enemies():
	var dwarf1:Node = _create_sprite("dwarf", Dwarf, _new_GroupName.enemies, 3, 3)
	dwarf1.init(3, 3, 100, 10)
	var dwarf2:Node = _create_sprite("dwarf", Dwarf, _new_GroupName.enemies, 9, 9)
	dwarf2.init(9, 9, 100, 10)

func _init_player():
	var pc:Node = _create_sprite("pc", Player, _new_GroupName.pc, 0, 0)
	pc.init(0, 0, 100, 10)
	emit_signal("OnPlayerCreated", pc)

func _create_sprite(name : String, prefab: PackedScene, group: String, x: int, y: int,
		x_offset: int = 0, y_offset: int = 0):
	var new_sprite := prefab.instance() as Sprite
	new_sprite.position = _new_ConvertCoord.index_to_vector(x, y, x_offset, y_offset)
	new_sprite.name = name
	new_sprite.add_to_group(group)

	add_child(new_sprite)
	return new_sprite
