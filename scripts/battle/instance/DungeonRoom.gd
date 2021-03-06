class_name DungeonRoom

# Room.gd
const Floor := preload("res://entity/Floor.tscn")
const Wall := preload("res://entity/Wall.tscn")
const Dwarf := preload("res://entity/Dwarf.tscn")

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

var items:Array = []

var maxRows:int
var maxCols:int
var startX:int
var startY:int

var loadedScenes:Array = []

var wasRoomVisited:bool = false

var roomId:int = -1

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
		var floorObj:Node = Utils.create_scene(loadedScenes, str(r) + "_" + str(c), Floor, Constants.room_floor, cell)
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

func _create_wall(r, c):
	var cell:DungeonCell = get_cell(r, c)
	var wall:Node = Utils.create_scene(loadedScenes, "wall", Wall, Constants.room_floor, cell)
	cell.init_entity(wall, Constants.ENTITY_TYPE.STATIC)
		
func generate_enemies(totalEnemiesToSpawn):
	for i in totalEnemiesToSpawn:
		spawnEnemy()

func spawnEnemy():
	# find free cells
	var freeCells:Array = []
	for cell in cells:
		if cell.is_empty() and cell.is_within_room_buffered(3):
			freeCells.append(cell)
	
	# choose random free cell
	var randomCell:DungeonCell = freeCells[randi() % freeCells.size()]

	# spawn random enemy
	var randomEnemyData:CharacterData = Dungeon.dataManager.get_random_enemy_data()
	var enemy:Node = Dungeon.load_character(loadedScenes, randomCell, randomEnemyData, Constants.ENTITY_TYPE.DYNAMIC, Constants.enemies, Constants.TEAM.ENEMY)
	enemies.append(enemy)

func generate_items(totalItemsToSpawn):
	for i in totalItemsToSpawn:
		spawnItem()

func spawnItem():
	# find free cells
	var freeCells:Array = []
	for cell in cells:
		if cell.is_empty():
			freeCells.append(cell)
	
	# choose random free cell
	var randomCell:DungeonCell = freeCells[randi() % freeCells.size()]

	# spawn random enemy
	var randomItemData:ItemData = Dungeon.dataManager.get_random_item_data()
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
			_show_debug(Dungeon.battleInstance.debugStartRoomColor)
		elif isEndRoom:
			_show_debug(Dungeon.battleInstance.debugEndRoomColor)
		elif isCriticalPathRoom:
			_show_debug(Dungeon.battleInstance.debugCriticalPathRoomColor)
	else:	
		var isPlayerCurrent:bool = Dungeon.player.is_in_room(self)
		var isPlayerPrevious:bool = Dungeon.player.is_prev_room(self)
		if isPlayerCurrent:
			_show()
			wasRoomVisited = true
		elif isPlayerPrevious:
			_dim()
		elif wasRoomVisited:
			_dim()
		else:
			_hide()
	
func update_entities():
	if Dungeon.player.cell.is_connection():
		return

	if enemies.size()>0:
		yield(Dungeon.battleInstance.get_tree().create_timer(Dungeon.battleInstance.timeBetweenMoves), "timeout")
	
	# ENEMIES
	for enemy in enemies:
		if !enemy.isDead:
			enemy.update()

# VISIBILITY
func _show():
	for cell in cells:
		cell.show()

func _dim():
	for cell in cells:
		cell.dim()

func _hide():
	for cell in cells:
		cell.hide()

func _show_debug(colorVal):
	for cell in cells:
		cell.showDebug(colorVal)

# ENTITY
func move_entity(entity, currentCell, newR:int, newC:int) -> bool:
	# within bounds of room
	if newC>=0 and newR>=0 and newC<maxCols and newR<maxRows:
		var cell:DungeonCell = get_cell(newR, newC)
		# empty cell
		if(!cell.has_entity()):
			currentCell.clear_entity()
			cell.init_entity(entity, Constants.ENTITY_TYPE.DYNAMIC)
			entity.move_to_cell(cell)
			return true
		elif(cell.is_entity_type(Constants.ENTITY_TYPE.DYNAMIC)):
			# Item
			if cell.entityObject is Item:
				entity.add_item(cell.entityObject)
				cell.entityObject.picked()
				items.erase(cell.entityObject)
				currentCell.clear_entity()
				cell.init_entity(entity, Constants.ENTITY_TYPE.DYNAMIC)
				entity.move_to_cell(cell)
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
			return true
	
	return false

func enemy_died(entity):
	enemies.remove(enemies.find(entity))

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
		if validCell!=null and !validCell.is_obstacle() and validCell.room == cell.room:
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

# HELPERS
func get_cell(r:int, c:int):
	return cells[r * maxCols + c]

func get_safe_starting_cell():
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
