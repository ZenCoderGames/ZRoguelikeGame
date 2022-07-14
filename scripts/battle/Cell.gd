# Cell.gd
var cellType:int = Constants.CELL_TYPE.NONE
var entityType:int = Constants.ENTITY_TYPE.NONE

var floorObject = null
var entity = null

var connectedCell = null

var room
var row:int
var col:int
var pos:Vector2

func _init(roomRef, r:int, c:int):
	room = roomRef
	row = r
	col = c
	pos = room.get_world_position(r, c)

# CELL TYPE
func init_cell(obj, cellTypeEnum:int):
	floorObject = obj
	set_cell_type(cellTypeEnum)

func set_cell_type(newCellType:int):
	cellType = newCellType

func is_cell_type(type:int):
	return cellType == type
	
# ENTITY TYPE
func init_entity(obj, type:int):
	entity = obj
	set_entity_type(type)
	floorObject.hide()
	
func set_entity_type(newEntityType:int):
	entityType = newEntityType

func is_entity_type(type:int):
	return entityType == type
	
func has_entity():
	return entityType != Constants.ENTITY_TYPE.NONE
	
func clear_entity():
	entity = null
	entityType = Constants.ENTITY_TYPE.NONE
	floorObject.show()

# CONNECTIONS
func connect_cell(conCell):
	set_cell_type(Constants.CELL_TYPE.CONNECTOR)
	connectedCell = conCell
	room.clean_up_loaded_scene(entity)
	room.register_cell_connection(self)

# HELPERS
func is_edge_of_room():
	return row==0 || col==0 || row==room.maxRows-1 || col==room.maxCols-1

func is_left_edge():
	return col==0

func is_right_edge():
	return col==room.maxCols-1

func is_top_edge():
	return row==0

func is_bot_edge():
	return row==room.maxRows-1

func is_corner():
	return (row==0 and col==0) or\
			(row==0 and col==room.maxCols-1) or\
		 	(col==0 and row==room.maxRows-1) or\
			(col==room.maxCols-1 and row==room.maxRows-1)

func is_middle_of_left_edge():
	return is_left_edge() and row == room.maxRows/2

func is_middle_of_right_edge():
	return is_right_edge() and row == room.maxRows/2

func is_middle_of_top_edge():
	return is_top_edge() and col == room.maxCols/2

func is_middle_of_bot_edge():
	return is_bot_edge() and col == room.maxCols/2

func is_x_adjacent(cell):
	return abs(pos.x - cell.pos.x) == Constants.STEP_X+1

func is_y_adjacent(cell):
	return abs(pos.y - cell.pos.y) == Constants.STEP_Y+1

func is_x_identical(cell):
	return abs(pos.x - cell.pos.x) == 0

func is_y_identical(cell):
	return abs(pos.y - cell.pos.y) == 0
