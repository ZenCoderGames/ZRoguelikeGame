# Cell.gd
var cellType:int = Constants.CELL_TYPE.NONE
var entityType:int = Constants.ENTITY_TYPE.NONE

var floorObject = null
var entity = null

var row:int
var col:int
var pos:Vector2

func _init(r:int, c:int):
	row = r
	col = c
	pos = Utils.index_to_vector(c, r, 0, 0)

func is_edge_of_room():
	return row==0 || col==0 || row==Constants.MAX_ROWS-1 || col==Constants.MAX_COLS-1

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
