# Cell.gd
var cellType:int = Constants.CELL_TYPE.NONE
var entityType:int = Constants.ENTITY_TYPE.NONE

var floorObject = null
var entityObject = null

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
	floorObject.get_child(0).text = ""
	set_cell_type(cellTypeEnum)

func set_cell_type(newCellType:int):
	cellType = newCellType

func is_cell_type(type:int):
	return cellType == type
	
func show_debug_path_cell(cost):
	floorObject.get_child(0).visible = true
	floorObject.get_child(0).text = str(cost)
	
# ENTITY TYPE
func init_entity(obj, type:int):
	entityObject = obj
	set_entity_type(type)
	floorObject.hide()
	
func set_entity_type(newEntityType:int):
	entityType = newEntityType

func is_entity_type(type:int):
	return entityType == type
	
func has_entity():
	return entityType != Constants.ENTITY_TYPE.NONE
	
func clear_entity():
	entityType = Constants.ENTITY_TYPE.NONE
	floorObject.show()
	entityObject = null
	
func unload_entity():
	room.clean_up_loaded_scene(entityObject)
	clear_entity()

# CONNECTIONS
func connect_cell(conCell):
	set_cell_type(Constants.CELL_TYPE.CONNECTOR)
	connectedCell = conCell
	room.register_cell_connection(self)
	unload_entity()

func has_connection():
	return connectedCell != null

# VISIBILITY
func show():
	floorObject.show()
	if entityObject!=null:
		floorObject.hide()
		entityObject.show()

	# color
	floorObject.modulate = Dungeon.battleInstance.showFloorColor
	if entityObject!=null:
		if is_entity_type(Constants.ENTITY_TYPE.STATIC):
			entityObject.modulate = Dungeon.battleInstance.showWallColor

func hide():
	floorObject.hide()
	if entityObject!=null:
		entityObject.hide()

func dim():
	floorObject.show()
	if entityObject!=null:
		floorObject.hide()
		entityObject.hide()
		
	# color
	floorObject.modulate = Dungeon.battleInstance.dimFloorColor
	if entityObject!=null:
		if is_entity_type(Constants.ENTITY_TYPE.STATIC):
			entityObject.show()
			entityObject.modulate = Dungeon.battleInstance.dimWallColor

func showDebug(colorVal):
	floorObject.show()
	if entityObject!=null:
		floorObject.hide()
		entityObject.show()
		
	# color
	floorObject.modulate = colorVal
	if entityObject!=null:
		if is_entity_type(Constants.ENTITY_TYPE.STATIC):
			entityObject.modulate = colorVal

# HELPERS
func is_obstacle():
	return entityType == Constants.ENTITY_TYPE.STATIC

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

func is_empty():
	return is_cell_type(Constants.CELL_TYPE.FLOOR) && !has_entity()

func highlight(color):
	floorObject.self_modulate = color
