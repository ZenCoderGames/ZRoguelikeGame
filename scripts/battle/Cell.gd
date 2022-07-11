# Cell.gd
var cellType:int = Constants.CELL_TYPE.NONE
var entityType:int = Constants.ENTITY_TYPE.NONE

var floorObject = null
var entity = null

var room
var row:int
var col:int
var pos:Vector2

func _init(roomRef, r:int, c:int):
	room = roomRef
	row = r
	col = c
	pos = room.get_world_position(r, c)

func is_edge_of_room():
	return row==0 || col==0 || row==room.maxRows-1 || col==room.maxCols-1

# CELL TYPE
func init_cell(obj, cellType:int):
	floorObject = obj
	set_cell_type(cellType)

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
