# Room.gd

const Cell = preload("res://scripts/battle/Cell.gd")
var cells:Array = []

const Floor := preload("res://sprite/Floor.tscn")
const Wall := preload("res://sprite/Wall.tscn")
const ArrowX := preload("res://sprite/ArrowX.tscn")
const ArrowY := preload("res://sprite/ArrowY.tscn")
const Dwarf := preload("res://sprite/Dwarf.tscn")

func _init():
	for r in Constants.MAX_ROWS:
		for c in Constants.MAX_COLS:
			cells.append(Cell.new(r, c))

func populate_room():
	# Init Floor
	for i in range(0, cells.size()):
		var r = i/Constants.MAX_COLS
		var c = i%Constants.MAX_COLS
		var cell = get_cell(r, c)
		#var cell = cells[i]
		var floorObj = Utils.create_scene(str(r) + "_" + str(c), Floor, Constants.room_floor, cell)
		cells[i].init_cell(floorObj, Constants.CELL_TYPE.FLOOR)

	_init_walls()
	_init_connectors()
	_init_enemies()

func _init_walls():
	var walls:Array = [5,5, 6,5, 7,5, 8,5]
	var i:int = 0
	while i < walls.size()-1:
		var cell = get_cell(walls[i], walls[i+1])
		var wall = Utils.create_scene("wall", Wall, Constants.room_floor, cell)
		cell.init_entity(wall, Constants.ENTITY_TYPE.STATIC)
		i = i+2
		
func _init_connectors():
	var cell = get_cell(0, 5)
	var arrowY = Utils.create_scene("arrow", ArrowY, Constants.room_floor, cell, 0, -20)
	cell.init_cell(arrowY, Constants.CELL_TYPE.CONNECTOR)
	
	cell = get_cell(7, 0)
	var arrowX = Utils.create_scene("arrow", ArrowX, Constants.room_floor, cell, -20)
	cell.init_cell(arrowX, Constants.CELL_TYPE.CONNECTOR)
	
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
	return cells[r * Constants.MAX_COLS + c]

func move_entity(entity, currentCell, newR:int, newC:int):
	if newC>=0 and newR>=0 and newC<Constants.MAX_COLS and newR<Constants.MAX_ROWS:
		var cell = get_cell(newR, newC)
		if(!cell.has_entity()):
			cell.init_entity(entity, Constants.ENTITY_TYPE.DYNAMIC)
			entity.move_to_cell(cell)
			currentCell.clear_entity()
