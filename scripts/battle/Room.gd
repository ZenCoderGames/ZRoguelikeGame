# Room.gd
const Floor := preload("res://entity/Floor.tscn")
const Wall := preload("res://entity/Wall.tscn")
const Dwarf := preload("res://entity/Dwarf.tscn")

const Cell = preload("res://scripts/battle/Cell.gd")
var cells:Array = []

var connectorCells:Array = []

var maxRows:int
var maxCols:int
var startX:int
var startY:int

func _init(mR, mC, sX, sY):
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
		var floorObj = Utils.create_scene(str(r) + "_" + str(c), Floor, Constants.room_floor, cell)
		cells[i].init_cell(floorObj, Constants.CELL_TYPE.FLOOR)

	_init_walls()
	#_init_enemies()

func _init_walls():
	# Connector Cells
	#connectorCells.append(get_cell(0, 5))
	#connectorCells.append(get_cell(7, 0))
	#connectorCells.append(get_cell(10, maxCols-1))
	
	# Room Walls
	for cell in cells:
		var foundConnectorCell:bool = false
		for connCell in connectorCells:
			if(cell==connCell):
				foundConnectorCell = true
				continue
		
		if foundConnectorCell:
			continue
		
		if(cell.is_edge_of_room()):
			_create_wall(cell.row, cell.col)
	
	# Obstacle Walls
	##var innerWalls:Array = [5,5, 6,5, 7,5, 8,5]
	##var i:int = 0
	##while i < innerWalls.size()-1:
	##	_create_wall(innerWalls[i], innerWalls[i+1])
	##	i = i+2
		
func _create_wall(r, c):
	var cell = get_cell(r, c)
	var wall = Utils.create_scene("wall", Wall, Constants.room_floor, cell)
	cell.init_entity(wall, Constants.ENTITY_TYPE.STATIC)
		
func _init_enemies():
	var cell =  get_cell(3, 3)
	var dwarf1:Node = Utils.create_scene("dwarf", Dwarf, Constants.enemies, cell)
	cell.init_entity(dwarf1, Constants.ENTITY_TYPE.DYNAMIC)
	dwarf1.init(cell, 100, 10)
	
	cell =  get_cell(9, 9)
	var dwarf2:Node = Utils.create_scene("dwarf", Dwarf, Constants.enemies, cell)
	cell.init_entity(dwarf2, Constants.ENTITY_TYPE.DYNAMIC)
	dwarf2.init(cell, 100, 10)

# HELPERS
func get_cell(r:int, c:int):
	return cells[r * maxCols + c]

func move_entity(entity, currentCell, newR:int, newC:int):
	if newC>=0 and newR>=0 and newC<maxCols and newR<maxRows:
		var cell = get_cell(newR, newC)
		if(!cell.has_entity()):
			cell.init_entity(entity, Constants.ENTITY_TYPE.DYNAMIC)
			entity.move_to_cell(cell)
			currentCell.clear_entity()

func get_random_connector_cell():
	randomize()
	return connectorCells[randi()%connectorCells.size()]

func get_safe_starting_cell():
	return get_cell(maxRows/2, maxCols/2)

func get_world_position(r: int, c: int) -> Vector2:
	var col_vector: int = startX + Constants.STEP_X * c
	var row_vector: int = startY + Constants.STEP_Y * r

	return Vector2(col_vector, row_vector)

func is_point_inside(pX:int, pY:int, buffer:int):
	var pXInside = pX >= startX - buffer and pX <= (startX + Constants.STEP_X * maxCols)
	var pYInside = pY >= startY - buffer and pY <= (startY + Constants.STEP_Y * maxRows)
	return pXInside and pYInside
