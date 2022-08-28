# Dungeon.gd
extends Node2D

# signals
signal OnPlayerCreated(newPlayer)
signal OnStartTurn()
signal OnEndTurn()
signal OnEnemyMovedAdjacentToPlayer(enemy)

var rooms:Array = []
const intersectionBuffer:int = 0

var player:Character = null
var turnsTaken:int = 0

var loadedScenes:Array = []

var battleInstance:BattleInstance

var dataManager:DungeonDataManager

func init(battleInst:BattleInstance):
	battleInstance = battleInst

func create() -> void:
	_init_rooms()
	_init_connections()
	_init_path()
	_init_data()
	_init_enemies()
	_init_items()
	_init_player()

func _init_rooms():
	rooms = []
	
	# Dungeon Size
	var numRooms := 10
	var roomMinRows := 9
	var roomMaxRows := 14
	var roomMinCols := 9
	var roomMaxCols := 14
	
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
		var newRoom:DungeonRoom = DungeonRoom.new(rooms.size(), numR, numC, 0, 0)
		if rooms.size()>0:
			# Choose a random room to start on
			var startSpawnRoom:DungeonRoom = rooms[randi() % rooms.size()]
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
				for conCell in con2Array:
					# found connection c1
					if c1>=0 and ((isYCheck and conCell.is_x_identical(con1Array[c1])) or (!isYCheck and conCell.is_y_identical(con1Array[c1]))):
						con1Array[c1].connect_cell(conCell)
						conCell.connect_cell(con1Array[c1])
						return
					# found connection c2
					if c2<arrayMidSize*2 and ((isYCheck and conCell.is_x_identical(con1Array[c2])) or (!isYCheck and conCell.is_y_identical(con1Array[c2]))):
						con1Array[c2].connect_cell(conCell)
						conCell.connect_cell(con1Array[c2])
						return

var costFromStart:Dictionary = {}
var roomsToVisit:Array = []
var visitedRooms:Dictionary = {}
var reverse_path:Array = []
var startRoom
var furthestRoom 
func _init_path():
	# reset variables
	startRoom = rooms[0]
	furthestRoom = null
	reverse_path = []
	visitedRooms = {}
	roomsToVisit = []
	costFromStart = {}
	# start with first room
	startRoom.isStartRoom = true
	costFromStart[startRoom] = 0
	roomsToVisit.append(startRoom)
	visitedRooms[startRoom] = true
	# do path calculations
	while roomsToVisit.size()>0:
		var room = roomsToVisit[0]
		for connection in room.connections:
			var connectedRoom = connection.connectedCell.room
			if visitedRooms.has(connectedRoom):
				continue
			roomsToVisit.append(connectedRoom)
			visitedRooms[connectedRoom] = true
			var pathCost = costFromStart[room]+1
			if !costFromStart.has(connectedRoom) or pathCost<costFromStart[connectedRoom]:
				costFromStart[connectedRoom] = pathCost
		roomsToVisit.remove(0)
	# find the furthest room
	var furthestCost:int = 0
	for room in rooms:
		if costFromStart[room] > furthestCost:
			furthestCost = costFromStart[room]
			furthestRoom = room
	furthestRoom.isEndRoom = true
	# find path
	reverse_path.append(furthestRoom)
	var room = furthestRoom
	while room!= startRoom:
		var shortestPathConnectedRoom = room.connections[0].connectedCell.room
		var shortestPathConnectionCost:int = costFromStart[shortestPathConnectedRoom]
		for connection in room.connections:
			var connectedRoom = connection.connectedCell.room
			var pathCost = costFromStart[connectedRoom]
			if pathCost < shortestPathConnectionCost:
				shortestPathConnectedRoom = connectedRoom
				shortestPathConnectionCost = pathCost
		room = shortestPathConnectedRoom
		room.isCriticalPathRoom = true
		reverse_path.append(room)
	reverse_path.append(startRoom)

func _init_data():
	dataManager = DungeonDataManager.new()

func _init_enemies():
	if battleInstance.dontSpawnEnemies:
		return

	if !battleInstance.debugSpawnEnemyInFirstRoom.empty():
		startRoom.generate_enemy(battleInstance.debugSpawnEnemyInFirstRoom)
	
	var minCostPerRoom:int = 5
	var extraCostForSingleRoom:int = 5
	var scalingCostPerRoom:int = 20
	var numCriticalPathRooms = reverse_path.size();
	for room in rooms:
		if room.isStartRoom:
			continue

		var encounterCost = minCostPerRoom + int(float(costFromStart[room])/float(numCriticalPathRooms) * float(scalingCostPerRoom))
		if room.connections.size()==1:
			encounterCost = encounterCost + extraCostForSingleRoom
		
		var currentCost:int = 0
		var enemyDataList:Array = Utils.duplicate_array(dataManager.enemyDataList)
		while(currentCost<encounterCost):
			var enemyData:CharacterData = enemyDataList[randi() % enemyDataList.size()]
			if currentCost + enemyData.cost<=encounterCost:
				if room.generate_enemy(enemyData.id):
					currentCost = currentCost + enemyData.cost
				else:
					break
			else:
				enemyDataList.erase(enemyData)
				if enemyDataList.size()==0:
					break

func _init_items():
	if battleInstance.dontSpawnItems:
		return

	if !battleInstance.debugSpawnItemInFirstRoom.empty():
		startRoom.generate_item(battleInstance.debugSpawnItemInFirstRoom)
		startRoom.generate_item("PRISMATIC_SHIELD")
	else:
		startRoom.generate_items(1)

	for room in rooms:
		if !room.isStartRoom:
			room.generate_items(randi() % 2)

func _init_player():
	var cell:DungeonCell = rooms[0].get_safe_starting_cell()
	player = load_character(loadedScenes, cell, dataManager.playerData, Constants.ENTITY_TYPE.DYNAMIC, Constants.pc, Constants.TEAM.PLAYER)
	emit_signal("OnPlayerCreated", player)
	_on_turn_taken(0, 0)
	player.connect("OnCharacterMove", self, "_on_turn_taken")
	player.equipment.connect("OnSpellActivated", self, "_on_player_spell_activated")

func _on_player_spell_activated(item):
	_on_turn_taken(0, 0)

func _on_turn_taken(x, y):
	emit_signal("OnStartTurn")
	player.pre_update()
	player.cell.room.pre_update_entities()

	player.update()
	player.cell.room.update_entities()

	turnsTaken += 1
	emit_signal("OnEndTurn")

	for room in rooms:
		room.update_visibility()

	player.post_update()
	player.cell.room.post_update_entities()

func clean_up():
	for loadedScene in loadedScenes:
		loadedScene.queue_free()
	loadedScenes.clear()
	
	player = null
	
	for room in rooms:
		room.clean_up()
	rooms.clear()
	
	turnsTaken = 0

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
	var p1 := Vector2(testRoom.startX, testRoom.startY)
	var p2 := Vector2(testRoom.startX + Constants.STEP_X * testRoom.maxCols, testRoom.startY)
	var p3 := Vector2(testRoom.startX, testRoom.startY + Constants.STEP_Y * testRoom.maxRows)
	var p4 := Vector2(testRoom.startX + Constants.STEP_X * testRoom.maxCols, testRoom.startY + Constants.STEP_Y * testRoom.maxRows)
	var p5 := Vector2(testRoom.get_center().x, testRoom.get_center().y)
	return room.is_point_inside(p1.x, p1.y, intersectionBuffer) or\
		   room.is_point_inside(p2.x, p2.y, intersectionBuffer) or\
		   room.is_point_inside(p3.x, p3.y, intersectionBuffer) or\
		   room.is_point_inside(p4.x, p4.y, intersectionBuffer) or\
		   room.is_point_inside(p5.x, p5.y, 0)

func load_character(parentContainer, cell, characterData, entityType, groupName, team):
	var charPrefab := load(str("res://", characterData.path))
	var charObject = Utils.create_scene(parentContainer, characterData.displayName, charPrefab, groupName, cell)
	cell.init_entity(charObject, entityType)
	charObject.init(characterData, team)
	charObject.move_to_cell(cell)
	if team == Constants.TEAM.PLAYER:
		charObject.self_modulate = battleInstance.view.playerDamageColor
	elif team == Constants.TEAM.ENEMY:
		charObject.self_modulate = battleInstance.view.enemyDamageColor
	return charObject

func load_item(parentContainer, cell, itemData, entityType, groupName):
	var itemPrefab := load(str("res://", itemData.path))
	var itemObject = Utils.create_scene(parentContainer, itemData.displayName, itemPrefab, groupName, cell)
	cell.init_entity(itemObject, entityType)
	itemObject.init(itemData, cell)
	if itemData.is_gear():
		itemObject.self_modulate = battleInstance.view.itemGearColor
	if itemData.is_consumable():
		itemObject.self_modulate = battleInstance.view.itemConsumableColor
	if itemData.is_spell():
		itemObject.self_modulate = battleInstance.view.itemSpellColor
	return itemObject

func create_delay(timeToDelay):
	yield(battleInstance.get_tree().create_timer(timeToDelay), "timeout")  

func get_adjacent_characters(character, relativeTeamType, numTiles:int=1):
	var currentPlayerRoom:DungeonRoom = player.currentRoom
	var adjacentChars:Array = []

	if Utils.is_relative_team(character, player, relativeTeamType) and Utils.is_adjacent(character, player, numTiles):
		adjacentChars.append(player)

	for enemy in currentPlayerRoom.enemies:
		if Utils.is_relative_team(character, enemy, relativeTeamType) and Utils.is_adjacent(character, enemy, numTiles):
			adjacentChars.append(enemy)
	
	return adjacentChars
