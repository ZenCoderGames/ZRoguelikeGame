class_name DungeonCell

var cellType:int = Constants.CELL_TYPE.NONE
var entityType:int = Constants.ENTITY_TYPE.NONE

var floorObject:Node2D = null
var entityObject:Node2D = null

var connectedCell:DungeonCell = null

var room
var row:int
var col:int
var pos:Vector2

func _init(roomRef,r:int,c:int):
	room = roomRef
	row = r
	col = c
	pos = room.get_world_position(r, c)

# CELL TYPE
func init_cell(obj:Node, cellTypeEnum:int):
	if floorObject!=null:
		room.clean_up_loaded_scene(floorObject)
	floorObject = obj
	if floorObject.get_child_count()>0:
		floorObject.get_child(0).text = ""
	set_cell_type(cellTypeEnum)

func set_cell_type(newCellType:int):
	cellType = newCellType

func is_cell_type(type:int):
	return cellType == type
	
func show_debug_path_cell(cost:int):
	if floorObject.get_child_count()>0:
		floorObject.get_child(0).visible = true
		floorObject.get_child(0).text = str(cost)

func is_connection():
	return is_cell_type(Constants.CELL_TYPE.CONNECTOR)
	
# ENTITY TYPE
func init_entity(obj:Node, type:int):
	entityObject = obj
	set_entity_type(type)
	#floorObject.hide()
	
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

func clear_entity_on_death():
	#if entityObject!=null:
	#	entityObject.hide()
	clear_entity()
	'''var deathNode:Node = floorObject.get_node("Death")
	deathNode.rotate(randf_range(0, 180))
	deathNode.visible = true'''
	
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
		#floorObject.hide()
		entityObject.show()

	# color
	if is_exit():
		floorObject.modulate = GameGlobals.battleInstance.view.showExitColor
	elif is_end():
		floorObject.modulate = GameGlobals.battleInstance.view.showEndColor
	else:
		floorObject.modulate = GameGlobals.battleInstance.view.showFloorColor
	if entityObject!=null:
		if is_entity_type(Constants.ENTITY_TYPE.STATIC):
			entityObject.modulate = GameGlobals.battleInstance.view.showWallColor

func hide():
	floorObject.hide()
	if entityObject!=null:
		entityObject.hide()

func dim():
	floorObject.show()
	if entityObject!=null:
		#floorObject.hide()
		entityObject.hide()
		
	# color
	if is_exit():
		floorObject.modulate = GameGlobals.battleInstance.view.dimExitColor
	elif is_end():
		floorObject.modulate = GameGlobals.battleInstance.view.dimEndColor
	else:
		floorObject.modulate = GameGlobals.battleInstance.view.dimFloorColor
	if entityObject!=null:
		if is_entity_type(Constants.ENTITY_TYPE.STATIC):
			entityObject.show()
			entityObject.modulate = GameGlobals.battleInstance.view.dimWallColor

func showDebug(colorVal):
	floorObject.show()
	if entityObject!=null:
		#floorObject.hide()
		entityObject.show()
		
	# color
	floorObject.modulate = colorVal
	if entityObject!=null:
		if is_entity_type(Constants.ENTITY_TYPE.STATIC):
			entityObject.modulate = colorVal

# HELPERS
func is_obstacle():
	return entityType == Constants.ENTITY_TYPE.STATIC

func is_exit():
	return cellType == Constants.CELL_TYPE.EXIT

func is_end():
	return cellType == Constants.CELL_TYPE.END

func is_edge_of_room():
	return row==0 || col==0 || row==room.maxRows-1 || col==room.maxCols-1

func is_within_room_buffered(buffer:int):
	return row>=buffer && col>=buffer && row<=room.maxRows-1-buffer && col<=room.maxCols-1-buffer

func is_within_room_buffered_specific(bufferRow:int, bufferCol:int):
	return row>=bufferRow && col>=bufferCol && row<=room.maxRows-1-bufferRow && col<=room.maxCols-1-bufferCol

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

func is_x_adjacent(newCell):
	return abs(pos.x - newCell.pos.x) == Constants.STEP_X+1

func is_y_adjacent(newCell):
	return abs(pos.y - newCell.pos.y) == Constants.STEP_Y+1

func is_row_adjacent(newCell):
	return abs(row - newCell.row) == 1

func is_col_adjacent(newCell):
	return abs(col - newCell.col) == 1

func is_rowcol_adjacent(cell):
	return is_row_adjacent(cell) or is_col_adjacent(cell)

func is_x_identical(cell):
	return abs(pos.x - cell.pos.x) == 0

func is_y_identical(cell):
	return abs(pos.y - cell.pos.y) == 0

func is_empty():
	return is_cell_type(Constants.CELL_TYPE.FLOOR) && !has_entity()

func highlight(color):
	floorObject.self_modulate = color
