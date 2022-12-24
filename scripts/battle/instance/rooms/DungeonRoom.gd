class_name DungeonRoom

# Room.gd

var cells:Array = []

# Wall references
var wallCellsTop:Array = []
var wallCellsRight:Array = []
var wallCellsBot:Array = []
var wallCellsLeft:Array = []

# Connections
var leftConnection = null
var rightConnection = null
var topConnection = null
var botConnection = null
var connections:Array = []

# Path
var isStartRoom:bool
var isCriticalPathRoom:bool
var isEndRoom:bool

# Enemies
var enemies:Array = []

# Doors
var doors:Array = [] 

# Items
var items:Array = []

var maxRows:int
var maxCols:int
var startX:int
var startY:int

var loadedScenes:Array = []

var wasRoomVisited:bool = false

var roomId:int = -1
var _processedEnemyIdx:int = -1
var _prevProcessedEnemy:Character = null

func _init(id, mR, mC, sX, sY):
	roomId = id
	maxRows = mR
	maxCols = mC
	startX = sX
	startY = sY

func initialize():
	for r in maxRows:
		for c in maxCols:
			cells.append(DungeonCell.new(self, r, c))
			
	populate()

func populate():
	# Init Floor
	for i in range(0, cells.size()):
		var r:int = i/maxCols
		var c:int = i%maxCols
		var cell:DungeonCell = get_cell(r, c)
		var floorObj:Node = Utils.create_scene(loadedScenes, str(r) + "_" + str(c), Constants.Floor, Constants.room_floor, cell)
		cells[i].init_cell(floorObj, Constants.CELL_TYPE.FLOOR)

	_init_walls()

func _init_walls():
	# Room Walls
	for cell in cells:
		if(cell.is_edge_of_room()):
			_create_wall(cell.row, cell.col)
			if cell.is_left_edge() and !cell.is_corner():
				wallCellsLeft.append(cell)
			if cell.is_right_edge() and !cell.is_corner():
				wallCellsRight.append(cell)
			if cell.is_top_edge() and !cell.is_corner():
				wallCellsTop.append(cell)
			if cell.is_bot_edge() and !cell.is_corner():
				wallCellsBot.append(cell)

func generate_obstacles(obstacleChance:float, minObstacles:int, maxObstacles:int):
	if Utils.random_chance(obstacleChance):
		return

	var numObstacles:int = minObstacles + randi() % (maxObstacles-minObstacles+1)

	var freeCells:Array = []
	for cell in cells:
		if cell.is_empty() and cell.is_within_room_buffered_specific(maxRows/2-1, maxCols/2-1):
			freeCells.append(cell)
			numObstacles = numObstacles - 1
			if numObstacles==0:
				break

	if freeCells.size()>0:
		randomize()
		freeCells.shuffle()
		for cell in freeCells:
			_create_wall(cell.row, cell.col)

func _create_wall(r, c):
	var cell:DungeonCell = get_cell(r, c)
	var wall:Node = Utils.create_scene(loadedScenes, "wall", Constants.Wall, Constants.room_floor, cell)
	cell.init_entity(wall, Constants.ENTITY_TYPE.STATIC)
		
func generate_enemies(totalEnemiesToSpawn):
	for i in totalEnemiesToSpawn:
		spawn_random_enemy()

func spawn_random_enemy():
	# find free cells
	var freeCells:Array = []
	for cell in cells:
		if cell.is_empty() and cell.is_within_room_buffered(3):
			freeCells.append(cell)

	# choose random free cell
	if freeCells.size()>0:
		randomize()
		freeCells.shuffle()
		var randomCell:DungeonCell = freeCells[randi() % freeCells.size()]

		# spawn random enemy
		var randomEnemyData:CharacterData = Dungeon.dataManager.get_random_enemy_data()
		var enemy:Node = Dungeon.load_character(loadedScenes, randomCell, randomEnemyData, Constants.ENTITY_TYPE.DYNAMIC, Constants.enemies, Constants.TEAM.ENEMY)
		enemies.append(enemy)
		return true
	else:
		return false

func generate_enemy(enemyId):
	# find free cells
	var freeCells:Array = []
	for cell in cells:
		if cell.is_empty() and cell.is_within_room_buffered(3):
			freeCells.append(cell)
	
	if freeCells.size()>0:
		# choose random free cell
		freeCells.shuffle()
		var randomCell:DungeonCell = freeCells[randi() % freeCells.size()]

		# spawn random enemy
		var randomEnemyData:CharacterData = Dungeon.dataManager.get_enemy_data(enemyId)
		var enemy:Node = Dungeon.load_character(loadedScenes, randomCell, randomEnemyData, Constants.ENTITY_TYPE.DYNAMIC, Constants.enemies, Constants.TEAM.ENEMY)
		enemies.append(enemy)
		return true
	else:
		return false

func generate_items(totalItemsToSpawn):
	for i in totalItemsToSpawn:
		spawnItem()

func spawnItem():
	# find free cells
	var freeCells:Array = []
	for cell in cells:
		if cell.is_empty() and cell.is_within_room_buffered(2):
			freeCells.append(cell)
	
	# choose random free cell
	var randomCell:DungeonCell = freeCells[randi() % freeCells.size()]

	# spawn random enemy
	var randomItemData:ItemData = Dungeon.dataManager.get_random_item_data()
	var item:Node = Dungeon.load_item(loadedScenes, randomCell, randomItemData, Constants.ENTITY_TYPE.DYNAMIC, Constants.items)
	items.append(item)

func generate_item(itemId):
	# find free cells
	var playerCell = get_safe_starting_cell()
	var freeCells:Array = []
	for cell in cells:
		if cell == playerCell:
			continue

		if cell.is_empty():
			freeCells.append(cell)
	
	# choose random free cell
	var randomCell:DungeonCell = freeCells[randi() % freeCells.size()]

	# spawn random enemy
	var randomItemData = Dungeon.dataManager.get_item_data(itemId)
	var item:Node = Dungeon.load_item(loadedScenes, randomCell, randomItemData, Constants.ENTITY_TYPE.DYNAMIC, Constants.items)
	items.append(item)

func register_cell_connection(myCell):
	if myCell.is_top_edge():
		topConnection = myCell
		connections.append(topConnection)
	if myCell.is_bot_edge():
		botConnection = myCell
		connections.append(botConnection)
	if myCell.is_left_edge():
		leftConnection = myCell
		connections.append(leftConnection)
	if myCell.is_right_edge():
		rightConnection = myCell
		connections.append(rightConnection)

func clean_up_loaded_scene(sceneToCleanUp):
	loadedScenes.erase(sceneToCleanUp)
	if sceneToCleanUp!=null:
		sceneToCleanUp.queue_free()

func clean_up():
	for loadedScene in loadedScenes:
		loadedScene.queue_free()
	loadedScenes.clear()
	cells.clear()

func update_visibility():
	# VISIBILITY
	if Dungeon.battleInstance.debugShowAllRooms:
		if isStartRoom:
			_show_debug(Dungeon.battleInstance.view.debugStartRoomColor)
		elif isEndRoom:
			_show_debug(Dungeon.battleInstance.view.debugEndRoomColor)
		elif isCriticalPathRoom:
			_show_debug(Dungeon.battleInstance.view.debugCriticalPathRoomColor)
	else:	
		var isPlayerCurrentRoom:bool = Dungeon.player.is_in_room(self)
		var isPlayerPreviousRoom:bool = Dungeon.player.is_prev_room(self)
		if isPlayerCurrentRoom:
			_show()
			wasRoomVisited = true
			_check_for_doors()
		elif isPlayerPreviousRoom:
			_dim()
		elif wasRoomVisited:
			_dim()
		else:
			_hide()

# VISIBILITY
func _show():
	for cell in cells:
		cell.show()

func _dim():
	for cell in cells:
		if cell != Dungeon.player.cell:
			cell.dim()

func _hide():
	for cell in cells:
		cell.hide()

func _show_debug(colorVal):
	for cell in cells:
		cell.showDebug(colorVal)

# DOORS
func _check_for_doors():
	if doors.empty():
		if enemies.size()>0 and !connections.has(Dungeon.player.cell):	
			_create_doors()

func _create_doors():
	for connection in connections:
		var doorObj = Utils.create_scene(loadedScenes, "door", Constants.Door, Constants.room_door, connection)
		connection.init_entity(doorObj, Constants.ENTITY_TYPE.STATIC)
		doors.append(doorObj)
		if connection == topConnection or connection == botConnection:
			doorObj.rotate(deg2rad(90))
	
	CombatEventManager.on_room_combat_started(self)

func _destroy_doors():
	for connection in connections:
		connection.unload_entity()
	doors.clear()

	CombatEventManager.on_room_combat_ended(self)

# ENTITY
func move_entity(entity, currentCell, newR:int, newC:int) -> bool:
	# within bounds of room
	if newC>=0 and newR>=0 and newC<maxCols and newR<maxRows:
		var cell:DungeonCell = get_cell(newR, newC)
		# empty cell
		if(!cell.has_entity()):
			currentCell.clear_entity()
			cell.init_entity(entity, Constants.ENTITY_TYPE.DYNAMIC)
			entity.move_to_cell(cell, true)
			return true
		elif(cell.is_entity_type(Constants.ENTITY_TYPE.DYNAMIC)):
			# Item
			if cell.entityObject is Item:
				var item = cell.entityObject
				entity.pick_item(item)
				Dungeon.add_to_dungeon_scenes(item)
				loadedScenes.erase(item)
				item.picked()
				items.erase(item)
				currentCell.clear_entity()
				cell.init_entity(entity, Constants.ENTITY_TYPE.DYNAMIC)
				entity.move_to_cell(cell, true)
				return true
			# Enemy
			if entity.is_opposite_team(cell.entityObject):
				entity.attack(cell.entityObject)
				return true
	# out of bounds of room
	else:
		# if there is a connection, move to the connected cell
		if currentCell.has_connection():
			entity.move_to_cell(currentCell.connectedCell)
			currentCell.connectedCell.init_entity(entity, Constants.ENTITY_TYPE.DYNAMIC)
			currentCell.clear_entity()
			entity.on_turn_completed()
			return true

	return false

func enemy_died(entity):
	enemies.remove(enemies.find(entity))
	if enemies.empty():
		_destroy_doors()

# DJIKSTRA MAP
var shortestNodeToStart = {}
var costFromStart = {}
var visitedCells = {}
func update_path_map():
	# reset variables
	var playerCell:DungeonCell = Dungeon.player.cell
	visitedCells = {}
	var cellsToVisit = []
	costFromStart = {}
	shortestNodeToStart = {}
	# start with first room
	costFromStart[playerCell] = 0
	cellsToVisit.append(playerCell)		
	visitedCells[playerCell] = true
	# do path calculations
	while cellsToVisit.size()>0:
		var currentCell:DungeonCell = cellsToVisit[0]
		var neighbors:Array = _find_valid_neighboring_cells(currentCell)
		for cell in neighbors:
			if visitedCells.has(cell):
				continue

			var pathCost:int = costFromStart[currentCell]+1
			cellsToVisit.append(cell)
			visitedCells[cell] = true
			if !costFromStart.has(cell) or pathCost<costFromStart[cell]:
				costFromStart[cell] = pathCost
				shortestNodeToStart[cell] = currentCell
		cellsToVisit.remove(0)

	# DEBUG DRAW
	var showDebug:bool = false
	if showDebug:
		for cell in cells:
			if costFromStart.has(cell):
				cell.show_debug_path_cell(costFromStart[cell])

func _find_valid_neighboring_cells(cell, onlyEmpty:bool = false):
	var validNeighborCells:Array = []
	var validCells:Array = []
	if cell.row+1<maxRows:
		validCells.append(get_cell(cell.row+1, cell.col))
	if cell.row-1>=0:
		validCells.append(get_cell(cell.row-1, cell.col))
	if cell.col+1>=0:
		validCells.append(get_cell(cell.row, cell.col+1))
	if cell.col-1>=0:
		validCells.append(get_cell(cell.row, cell.col-1))

	for validCell in validCells:
		if validCell!=null and validCell.room == cell.room and !validCell.is_obstacle() and !validCell.is_exit() and !validCell.is_end():
			if !onlyEmpty or validCell.is_empty():
				validNeighborCells.append(validCell)

	return validNeighborCells

func find_next_best_path_cell(currentCell):
	var neighbors:Array = _find_valid_neighboring_cells(currentCell, true)
	if neighbors.size()>0:
		var lowestCost:int = costFromStart[neighbors[0]]
		var lowestNeighbor = neighbors[0]
		for cell in neighbors:
			if costFromStart[cell] < lowestCost:
				lowestCost = costFromStart[cell]
				lowestNeighbor = cell
			# if the costs are the same, choose the closest to the player
			elif costFromStart[cell] == lowestCost and\
				Dungeon.player.cell.pos.distance_to(cell.pos)<Dungeon.player.cell.pos.distance_to(lowestNeighbor.pos):
				lowestNeighbor = cell
				
		return lowestNeighbor

	""" Alt method: Use Shortest Node Dict
	if shortestNodeToStart.has(currentCell):
		return shortestNodeToStart[currentCell]"""

	return null

func set_as_end_room():
	isEndRoom = true

	# find free cells
	var freeCells:Array = []
	for cell in cells:
		if cell.is_empty():
			freeCells.append(cell)
	
	# choose random free cell
	var exitCell:DungeonCell = freeCells[randi() % freeCells.size()]

	var exitObj:Node = null
	if Dungeon.battleInstance.is_last_level():
		exitObj = Utils.create_scene(loadedScenes, "end", Constants.End, Constants.room_end, exitCell)
		exitCell.init_cell(exitObj, Constants.CELL_TYPE.END)
	else:
		exitObj = Utils.create_scene(loadedScenes, "exit", Constants.Exit, Constants.room_exit, exitCell)
		exitCell.init_cell(exitObj, Constants.CELL_TYPE.EXIT)

func pre_update_entities():
	for enemy in enemies:
		enemy.pre_update()

func update_entities():
	if Dungeon.player.cell.is_connection() or enemies.size()==0:
		CombatEventManager.on_all_enemy_turn_completed(self)
		return

	_processedEnemyIdx = -1
	_prevProcessedEnemy = null
	_update_next_enemy()

func _update_next_enemy():
	_processedEnemyIdx = _processedEnemyIdx + 1
	# Check for end of enemy list
	if enemies==null or _processedEnemyIdx>=enemies.size():
		CombatEventManager.on_all_enemy_turn_completed(self)
		return

	if _prevProcessedEnemy!=null:
		_prevProcessedEnemy.disconnect("OnTurnCompleted", self, "_update_next_enemy")

	var nextEnemy:Character = enemies[_processedEnemyIdx]
	if nextEnemy.isDead:
		_update_next_enemy()
	else:
		_prevProcessedEnemy = nextEnemy
		nextEnemy.connect("OnTurnCompleted", self, "_update_next_enemy")
		if Utils.is_adjacent(nextEnemy, Dungeon.player):
			yield(Dungeon.battleInstance.get_tree().create_timer(Constants.TIME_BETWEEN_MOVES_ADJACENT_TO_PLAYER), "timeout")
		else:
			yield(Dungeon.battleInstance.get_tree().create_timer(Constants.TIME_BETWEEN_MOVES), "timeout")
		nextEnemy.update()

func post_update_entities():
	for enemy in enemies:
		enemy.post_update()

# HELPERS
func get_cell(r:int, c:int):
	if r<0 or c<0 or r>=maxRows or c>=maxCols:
		return null
		
	return cells[r * maxCols + c]

func get_safe_starting_cell():
	var freeCells:Array = []
	for cell in cells:
		if cell.is_empty() and cell.is_within_room_buffered(3):
			freeCells.append(cell)
	
	if freeCells.size()>0:
		# choose random free cell
		freeCells.shuffle()
		return freeCells[randi() % freeCells.size()]

	return get_cell(maxRows/2, maxCols/2)

func get_world_position(r: int, c: int) -> Vector2:
	var col_vector:int = startX + Constants.STEP_X * c
	var row_vector:int = startY + Constants.STEP_Y * r

	return Vector2(col_vector, row_vector)

func is_point_inside(pX:int, pY:int, buffer:int):
	var pXInside:bool = pX >= startX - buffer and pX <= (startX + Constants.STEP_X * maxCols) - buffer
	var pYInside:bool = pY >= startY - buffer and pY <= (startY + Constants.STEP_Y * maxRows) - buffer
	return pXInside and pYInside

func get_center():
	return Vector2(startX + Constants.STEP_X/2 * maxCols, startY + Constants.STEP_Y/2 * maxRows)
	
func get_size():
	return Vector2(Constants.STEP_X * maxCols, Constants.STEP_Y * maxRows)

func get_half_size():
	return Vector2(Constants.STEP_X/2 * maxCols, Constants.STEP_Y/2 * maxRows)
