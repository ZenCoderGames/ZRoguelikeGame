# Dungeon.gd

extends Node2D

const Player := preload("res://entity/Player.tscn")
const Room := preload("res://scripts/battle/Room.gd")

# signals
signal OnPlayerCreated(newPlayer)

var rooms:Array = []
const intersectionBuffer:int = 0

var player:Node = null
var turnsTaken:int = 0

var loadedScenes:Array = []

func create() -> void:
	_init_rooms()
	_init_connections()
	_init_player()

func _init_rooms():
	# Dungeon Size
	var numRooms := 9
	var roomMinRows := 8
	var roomMaxRows := 16
	var roomMinCols := 8
	var roomMaxCols := 16
	
	# Choose a leaning direction for less sprawled paths
	var xDirn = 1 if randi() % 100 < 50 else -1
	var yDirn = 1 if randi() % 100 < 50 else -1
	# Room - maxRows, maxCols, StartX, StartY
	var numIterations = 0
	var maxIterations = 100
	while rooms.size() < numRooms:
		numIterations += 1
		if numIterations>=maxIterations:
			break
		
		randomize()
		var numR:int = roomMinRows + randi() % (roomMaxRows - roomMinRows + 1)
		var numC:int = roomMinCols + randi() % (roomMaxCols - roomMinCols + 1)
		var newRoom = Room.new(rooms.size(), numR, numC, 0, 0)
		if rooms.size()>0:
			# Choose a random room to start on
			var startSpawnRoom = rooms[randi() % rooms.size()]
			# Choose to start either at different ends of the start room
			var startPosType = randi() % 4
			# top left
			if startPosType == 0:
				newRoom.startX = startSpawnRoom.startX
				newRoom.startY = startSpawnRoom.startY
			# bot left
			elif startPosType == 1:
				newRoom.startX = startSpawnRoom.startX
				newRoom.startY = startSpawnRoom.startY + startSpawnRoom.get_size().y - newRoom.get_size().y
			# top right
			elif startPosType == 1:
				newRoom.startX = startSpawnRoom.startX + startSpawnRoom.get_size().x - newRoom.get_size().x
				newRoom.startY = startSpawnRoom.startY
			# bot right
			elif startPosType == 1:
				newRoom.startX = startSpawnRoom.startX + startSpawnRoom.get_size().x - newRoom.get_size().x
				newRoom.startY = startSpawnRoom.startY + startSpawnRoom.get_size().y - newRoom.get_size().y
			# Choose a random direction
			var randomDirn := randi() % 2
			var moveX = 0
			var moveY = 0
			if randomDirn == 0 :
				moveX = xDirn
			elif randomDirn == 1:
				moveY = yDirn
			# move out of start spawn room
			while is_intersecting_with_room(newRoom, startSpawnRoom):
				newRoom.startX += moveX * 1 # Constants.STEP_X
				newRoom.startY += moveY * 1 # Constants.STEP_Y
				
			# if you are still intersecting with a room,
			# fail and find a different spawn room
			if is_intersecting_with_any_room(newRoom):
				newRoom = null
				continue
			
		# now that rooms isn't colliding, initialize
		newRoom.initialize()
		rooms.append(newRoom)

func _init_connections():
	# Try and find connections for each wall in each room
	for currentRoom in rooms:
		for room in rooms:
			if currentRoom == room:
				continue

			# check for Top connection
			findConnection(currentRoom.topConnection, room.botConnection, currentRoom.wallCellsTop, room.wallCellsBot, true)
			# check for Bot connection
			findConnection(currentRoom.botConnection, room.topConnection, currentRoom.wallCellsBot, room.wallCellsTop, true)
			# check for Left connection
			findConnection(currentRoom.leftConnection, room.rightConnection, currentRoom.wallCellsLeft, room.wallCellsRight, false)
			# check for Right connection
			findConnection(currentRoom.rightConnection, room.leftConnection, currentRoom.wallCellsRight, room.wallCellsLeft, false)
			

func findConnection(con1, con2, con1Array, con2Array, isYCheck):
	if con1==null and con2==null:
		# if this is an adjacent y room, continue to check it
		if (isYCheck and con1Array[0].is_y_adjacent(con2Array[0])) or\
			(!isYCheck and con1Array[0].is_x_adjacent(con2Array[0])):
			var arrayMidSize:int = con1Array.size()/2
			# check cells from the middle outwards
			for i in arrayMidSize:
				var c1:int = arrayMidSize - i
				var c2:int = arrayMidSize + i
				for botCell in con2Array:
					# found connection c1
					if c1>=0 and ((isYCheck and botCell.is_x_identical(con1Array[c1])) or (!isYCheck and botCell.is_y_identical(con1Array[c1]))):
						con1Array[c1].connect_cell(botCell)
						botCell.connect_cell(con1Array[c1])
						return
					# found connection c2
					if c2<arrayMidSize*2 and ((isYCheck and botCell.is_x_identical(con1Array[c2])) or (!isYCheck and botCell.is_y_identical(con1Array[c2]))):
						con1Array[c2].connect_cell(botCell)
						botCell.connect_cell(con1Array[c2])
						return

		
func _init_player():
	var cell = rooms[0].get_safe_starting_cell()
	player = Utils.create_scene(loadedScenes, "player", Player, Constants.pc, cell)
	player.init(100, 10)
	player.move_to_cell(cell)
	emit_signal("OnPlayerCreated", player)
	_on_turn_taken(0, 0)
	player.connect("OnCharacterMove", self, "_on_turn_taken") 

func _on_turn_taken(x, y):
	turnsTaken += 1
	for room in rooms:
		room.update()

func clean_up():
	for loadedScene in loadedScenes:
		loadedScene.queue_free()
	loadedScenes.clear()
	
	player = null
	
	for room in rooms:
		room.clean_up()
	rooms.clear()

# HELPERS
func is_intersecting_with_any_room(testRoom):
	for room in rooms:
		if is_intersecting_with_room(testRoom, room) or\
			is_intersecting_with_room(room, testRoom) :
			return true
	
	return false
	
func is_intersecting_with_room(testRoom, room):
	return is_intersecting_with_room_test(testRoom, room) or\
			is_intersecting_with_room_test(room, testRoom)

func is_intersecting_with_room_test(testRoom, room):
	var p1 = Vector2(testRoom.startX, testRoom.startY)
	var p2 = Vector2(testRoom.startX + Constants.STEP_X * testRoom.maxCols, testRoom.startY)
	var p3 = Vector2(testRoom.startX, testRoom.startY + Constants.STEP_Y * testRoom.maxRows)
	var p4 = Vector2(testRoom.startX + Constants.STEP_X * testRoom.maxCols, testRoom.startY + Constants.STEP_Y * testRoom.maxRows)
	var p5 = Vector2(testRoom.get_center().x, testRoom.get_center().y)
	return room.is_point_inside(p1.x, p1.y, intersectionBuffer) or\
		   room.is_point_inside(p2.x, p2.y, intersectionBuffer) or\
		   room.is_point_inside(p3.x, p3.y, intersectionBuffer) or\
		   room.is_point_inside(p4.x, p4.y, intersectionBuffer) or\
		   room.is_point_inside(p5.x, p5.y, 0)
