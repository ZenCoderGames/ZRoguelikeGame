# Room.gd
const Floor := preload("res://entity/Floor.tscn")
const Wall := preload("res://entity/Wall.tscn")
const Dwarf := preload("res://entity/Dwarf.tscn")

const Cell = preload("res://scripts/battle/Cell.gd")
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
			cells.append(Cell.new(self, r, c))
			
	populate()

func populate():
	# Init Floor
	for i in range(0, cells.size()):
		var r = i/maxCols
		var c = i%maxCols
		var cell = get_cell(r, c)
		var floorObj = Utils.create_scene(loadedScenes, str(r) + "_" + str(c), Floor, Constants.room_floor, cell)
		cells[i].init_cell(floorObj, Constants.CELL_TYPE.FLOOR)

	_init_walls()
	#_init_enemies()

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
	var cell = get_cell(r, c)
	var wall = Utils.create_scene(loadedScenes, "wall", Wall, Constants.room_floor, cell)
	cell.init_entity(wall, Constants.ENTITY_TYPE.STATIC)
		
func generate_enemies(totalEnemiesToSpawn):
	for i in totalEnemiesToSpawn:
		spawnEnemy()

func spawnEnemy():
	# find free cells
	var freeCells:Array = []
	for cell in cells:
		if cell.is_empty() and !cell.is_edge_of_room():
			freeCells.append(cell)
	
	# choose random free cell
	var randomCell = freeCells[randi() % freeCells.size()]
	var dwarf:Node = Utils.create_scene(loadedScenes, "dwarf", Dwarf, Constants.enemies, randomCell)
	randomCell.init_entity(dwarf, Constants.ENTITY_TYPE.DYNAMIC)
	dwarf.init(20, 2, Constants.TEAM.ENEMY)
	dwarf.move_to_cell(randomCell)
	enemies.append(dwarf)

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
	# ENEMIES
	for enemy in enemies:
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
		var cell = get_cell(newR, newC)
		# empty cell
		if(!cell.has_entity()):
			currentCell.clear_entity()
			cell.init_entity(entity, Constants.ENTITY_TYPE.DYNAMIC)
			entity.move_to_cell(cell)
			return true
		elif(cell.is_entity_type(Constants.ENTITY_TYPE.DYNAMIC)):
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

# HELPERS
func get_cell(r:int, c:int):
	return cells[r * maxCols + c]

func get_safe_starting_cell():
	return get_cell(maxRows/2, maxCols/2)

func get_world_position(r: int, c: int) -> Vector2:
	var col_vector: int = startX + Constants.STEP_X * c
	var row_vector: int = startY + Constants.STEP_Y * r

	return Vector2(col_vector, row_vector)

func is_point_inside(pX:int, pY:int, buffer:int):
	var pXInside = pX >= startX - buffer and pX <= (startX + Constants.STEP_X * maxCols) - buffer
	var pYInside = pY >= startY - buffer and pY <= (startY + Constants.STEP_Y * maxRows) - buffer
	return pXInside and pYInside

func get_center():
	return Vector2(startX + Constants.STEP_X/2 * maxCols, startY + Constants.STEP_Y/2 * maxRows)
	
func get_size():
	return Vector2(Constants.STEP_X * maxCols, Constants.STEP_Y * maxRows)

func get_half_size():
	return Vector2(Constants.STEP_X/2 * maxCols, Constants.STEP_Y/2 * maxRows)
