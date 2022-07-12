# Dungeon.gd

extends Node2D

const Player := preload("res://entity/Player.tscn")
const Room := preload("res://scripts/battle/Room.gd")

# signals
signal OnPlayerCreated(newPlayer)

var rooms:Array = []
var currentRoom = null
var intersectionBuffer:int = 20

func _ready() -> void:
	yield(get_tree(), "idle_frame")
	_init_rooms()
	_init_player()

func _init_rooms():
	# Dungeon Size
	var sizeX := 500
	var sizeY := 500
	var numRooms := 9
	var roomMinRows := 12
	var roomMaxRows := 12
	var roomMinCols := 12
	var roomMaxCols := 12
	
	# Room - maxRows, maxCols, StartX, StartY
	while rooms.size() < numRooms:
		randomize()
		var numR:int = roomMinRows + randi() % (roomMaxRows - roomMinRows + 1)
		var numC:int = roomMinCols + randi() % (roomMaxCols - roomMinCols + 1)
		var newRoom = Room.new(numR, numC, 0, 0)
		if rooms.size()>0:
			# Choose a random room to start on
			var randomRoom = rooms[randi() % rooms.size()]
			newRoom.startX = randomRoom.startX
			newRoom.startY = randomRoom.startY
			# Choose a random direction
			var randomDirn := randi() % 4 # 0 - right, clockwise
			var moveX = 0
			var moveY = 0
			if randomDirn == 0:
				moveX = 1
			elif randomDirn == 1:
				moveY = 1
			elif randomDirn == 2:
				moveY = -1
			elif randomDirn == 3:
				moveX = -1
			while is_intersecting_with_any_room(newRoom):
				newRoom.startX += moveX
				newRoom.startY += moveY
			
		# now that rooms isn't colliding, initialize
		newRoom.initialize()
		rooms.append(newRoom)
		
	# Choose a random room
	currentRoom = rooms[0]

func _init_player():
	var cell = currentRoom.get_safe_starting_cell()
	var player:Node = Utils.create_scene("player", Player, Constants.pc, cell)
	player.init(cell, 100, 10)
	emit_signal("OnPlayerCreated", player)

# HELPERS
func is_intersecting_with_any_room(testRoom):
	for room in rooms:
		if is_intersecting_with_room(testRoom, room) or\
			is_intersecting_with_room(room, testRoom) :
			return true
	
	return false
	
func is_intersecting_with_room(testRoom, room):
	var p1 = Vector2(testRoom.startX, testRoom.startY)
	var p2 = Vector2(testRoom.startX + Constants.STEP_X * testRoom.maxCols, testRoom.startY)
	var p3 = Vector2(testRoom.startX, testRoom.startY + Constants.STEP_Y * testRoom.maxRows)
	var p4 = Vector2(testRoom.startX + Constants.STEP_X * testRoom.maxCols, testRoom.startY + Constants.STEP_Y * testRoom.maxRows)
	return room.is_point_inside(p1.x, p1.y, intersectionBuffer) or\
		   room.is_point_inside(p2.x, p2.y, intersectionBuffer) or\
		   room.is_point_inside(p3.x, p3.y, intersectionBuffer) or\
		   room.is_point_inside(p4.x, p4.y, intersectionBuffer)
