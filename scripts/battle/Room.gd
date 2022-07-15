# Room.gd
const Floor := preload("res://entity/Floor.tscn")
const Wall := preload("res://entity/Wall.tscn")
const Dwarf := preload("res://entity/Dwarf.tscn")

const Cell = preload("res://scripts/battle/Cell.gd")
var cells:Array = []

# wall references
var wallCellsTop:Array = []
var wallCellsRight:Array = []
var wallCellsBot:Array = []
var wallCellsLeft:Array = []

# connections
var leftConnection = null
var rightConnection = null
var topConnection = null
var botConnection = null

var maxRows:int
var maxCols:int
var startX:int
var startY:int

var loadedScenes:Array = []

var wasRoomVisited:bool = false

var player = null
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
		
func _init_enemies():
	var cell =  get_cell(3, 3)
	var dwarf1:Node = Utils.create_scene(loadedScenes, "dwarf", Dwarf, Constants.enemies, cell)
	cell.init_entity(dwarf1, Constants.ENTITY_TYPE.DYNAMIC)
	dwarf1.init(cell, 100, 10)
	
	cell =  get_cell(9, 9)
	var dwarf2:Node = Utils.create_scene(loadedScenes, "dwarf", Dwarf, Constants.enemies, cell)
	cell.init_entity(dwarf2, Constants.ENTITY_TYPE.DYNAMIC)
	dwarf2.init(cell, 100, 10)

func register_cell_connection(myCell):
	if myCell.is_top_edge():
		topConnection = myCell
	if myCell.is_bot_edge():
		botConnection = myCell
	if myCell.is_left_edge():
		leftConnection = myCell
	if myCell.is_right_edge():
		rightConnection = myCell

func clean_up_loaded_scene(sceneToCleanUp):
	loadedScenes.erase(sceneToCleanUp)
	sceneToCleanUp.queue_free()

func clean_up():
	for loadedScene in loadedScenes:
		loadedScene.queue_free()
	loadedScenes.clear()
	cells.clear()

func update():
	var isPlayerCurrent:bool = Dungeon.player.is_in_room(self)
	var isPlayerPrevious:bool = Dungeon.player.is_prev_room(self)
	if isPlayerCurrent:
		_show()
		wasRoomVisited = true
	elif isPlayerPrevious:
		_show()
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
		cell.dim()

func _hide():
	for cell in cells:
		cell.hide()

# ENTITY
func move_entity(entity, currentCell, newR:int, newC:int) -> bool:
	# within bounds of room
	if newC>=0 and newR>=0 and newC<maxCols and newR<maxRows:
		var cell = get_cell(newR, newC)
		if(!cell.has_entity()):
			cell.init_entity(entity, Constants.ENTITY_TYPE.DYNAMIC)
			entity.move_to_cell(cell)
			currentCell.clear_entity()
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
